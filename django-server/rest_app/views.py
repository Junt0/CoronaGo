from django.contrib.auth import get_user_model
from django.contrib.auth.models import User
from django.http import HttpResponse, Http404
from django.shortcuts import render
from django.utils.encoding import force_text
from django.utils.http import urlsafe_base64_decode
from django.views.generic import View
from rest_framework import generics
from rest_framework import permissions
from rest_framework.authtoken.models import Token
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.generics import get_object_or_404
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import mixins

from rest_app.custom_permissions import IsVerified
from rest_app.models import Profile, UserInteraction
from rest_app.serializers import InteractionsLastModified, ProfileSerializer, UserInteractionSerializer, UserSignupSerializer
from rest_app.tokens import account_activation_token


def home(request):
    return render(request, 'home.html')


class GetProfile(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]
    serializer_class = ProfileSerializer
    model = Profile

    def get_object(self):
        username = self.kwargs['username']
        user = get_object_or_404(User, username=username)
        return Profile.objects.get(user=user)


class GetProfileInteractions(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]
    serializer_class = UserInteractionSerializer
    model = UserInteraction

    def get_queryset(self):
        profile = Profile.objects.get(user=self.request.user)
        return profile.interactions


class GetInteraction(APIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]
    serializer_class = UserInteractionSerializer
    model = UserInteraction

    def get_object(self):
        code = self.kwargs['code']
        return UserInteraction.objects.get(unique_id=code)

    def get(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.serializer_class(instance)

        request_prof = Profile.objects.get(user=request.user)
        if request_prof not in instance.participants.all():
            return Response(status=401)
        return Response(serializer.data)


class RequestProfile(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]
    serializer_class = ProfileSerializer
    model = Profile

    def get_object(self):
        user = self.request.user
        return Profile.objects.get(user=user)


class CreateInteraction(APIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]

    def get(self, request):
        prof = Profile.objects.get(user=request.user)
        if prof.has_running_interactions is False:
            interaction = UserInteraction.start(creator=prof)

            return Response({
                'interaction_code': interaction.unique_id,
                'detail': 'Interaction successfully created',
            })
        else:
            return Response({
                'detail': 'You can only have one interaction running at a time'
            }, status=403)


class JoinInteraction(APIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]

    def get_interaction(self, uuid):
        try:
            return UserInteraction.objects.get(unique_id=uuid)
        except UserInteraction.DoesNotExist:
            raise Http404

    def get(self, request, code):
        user_profile = Profile.objects.get(user=request.user)
        if user_profile.has_running_interactions is False:
            interaction = self.get_interaction(code)
            interaction.add_participants([user_profile])
            return Response({
                'interaction_code': interaction.unique_id,
                'detail': 'The interaction was joined'
            })

        return Response({
            'detail': 'You are only able to have one interaction running at a time'
        }, status=403)


class EndInteraction(APIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]

    def get_object(self, uuid):
        try:
            return UserInteraction.objects.get(unique_id=uuid)
        except UserInteraction.DoesNotExist:
            raise Http404

    def get(self, request, code):
        interaction = self.get_object(code)
        if self.is_creator(request.user, interaction):
            interaction.end()
            return Response({'detail': 'The interaction was ended'})
        else:
            return Response({'detail': 'Only the creator of the interaction can end it'}, status=403)

    def is_creator(self, profile: Profile, interaction: UserInteraction):
        return profile == interaction.creator.user


class LastModifiedInteractions(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]
    serializer_class = InteractionsLastModified
    model = UserInteraction

    def get_queryset(self):
        profile = Profile.objects.get(user=self.request.user)
        return profile.interactions


class AuthSignup(APIView):
    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = UserSignupSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.data
            user = self.signup(
                data['email'], data['username'], data['password'])

            if user is not None:
                profile = Profile.brand_new(user)
                profile.send_verification_email()
                return Response({'detail': 'Please check your email for a verification link'})

        return Response({'detail': 'A user with those credentials already exists'}, status=403)

    def signup(self, email, username, password):
        User = get_user_model()

        # Create a user if no users with the same email exist.
        try:
            user = User.objects.get(email=email)
            return None
        except User.DoesNotExist:
            user = User.objects.create(email=email, username=username)
            user.set_password(password)
            user.is_active = False
            user.save()
            return user


class VerifyAccount(View):
    template_name = 'VerifyAccountConfirmPage.html'

    def get(self, request, uidb64, token):
        try:
            uid = force_text(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)
        except(TypeError, ValueError, OverflowError, User.DoesNotExist):
            user = None
        if user is not None and account_activation_token.check_token(user, token):
            if user.is_active:
                return HttpResponse('This activation link has expired!')
            else:
                user.is_active = True
                user.save()
                return HttpResponse('Thank you for your email confirmation. Now you may login your account.')
        else:
            return HttpResponse('This activation link has expired!')


class AuthGetToken(ObtainAuthToken):

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(
            data=request.data, context={'request': request})
        val = serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        if user.is_active:
            token, created = Token.objects.get_or_create(user=user)
            return Response({'token': token.key})
        else:
            return Response({'detail': 'Please check your email for a verification link'})
