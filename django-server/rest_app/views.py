from django.contrib.auth import get_user_model
from django.contrib.auth.models import User, Group
from django.http import HttpResponse, Http404
from django.shortcuts import render
from django.utils.decorators import method_decorator
from django.utils.encoding import force_text
from django.utils.http import urlsafe_base64_decode
from django.views.decorators.csrf import csrf_exempt
from django.views.generic import TemplateView, View
from rest_framework import viewsets
from rest_framework import permissions
from rest_framework.authtoken.models import Token
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.parsers import JSONParser
from rest_framework.response import Response
from rest_framework.views import APIView

from rest_app.custom_permissions import IsVerified
from rest_app.models import Profile, UserInteraction
from rest_app.tokens import account_activation_token
from .serializers import UserSerializer, ProfileSerializer, UserSignupSerializer
from rest_framework import generics, mixins
from django.middleware.csrf import get_token


def home(request):
    return render(request, 'home.html')


class RequestUserProf(APIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]

    def get(self, request, pk):
        user_obj = User.objects.get(id=pk)
        profile = Profile.objects.get(user=user_obj)
        return Response(ProfileSerializer(profile).data)


class CreateInteraction(APIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]

    def get(self, request):
        prof = Profile.objects.get(user=request.user)
        if self.no_other_interactions(prof):
            interaction = UserInteraction.start(creator=prof)

            return Response({
                'interaction_code': interaction.unique_id
            })
        else:
            return Response({
                'error': 'You are only able to have one interaction running at a time'
            })


    def no_other_interactions(self, profile):
        return profile.interactions is None


class JoinInteraction(APIView):
    permission_classes = [permissions.IsAuthenticated, IsVerified]

    def get_interaction(self, uuid):
        try:
            return UserInteraction.objects.get(unique_id=uuid)
        except UserInteraction.DoesNotExist:
            raise Http404

    def get(self, request, code):
        prof = Profile.objects.get(user=request.user)
        if self.no_other_interactions(prof):
            interaction = self.get_interaction(code)
            interaction.add_participants([request.user])
            return Response({
                'success': f'Interaction: {interaction.unique_id} was joined successfully'
            })
        else:
            return Response({
                'error': 'You are only able to have one interaction running at a time'
            })

    def no_other_interactions(self, profile):
        return profile.interactions is None


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

    def is_creator(self, user: User, interaction: UserInteraction):
        return user == interaction.creator.user


class AuthSignup(APIView):
    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = UserSignupSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.data
            user = self.signup(data['email'], data['username'], data['password'])

            if user is not None:
                profile = Profile.brand_new(user)
                profile.send_verification_email()
                return Response({
                    'success': 'Please check your email for a verification link'
                })
        return Response({
            'error': 'An error has occurred with the creation of your account'
        })

    def signup(self, email, username, password):
        User = get_user_model()

        # create a user if no users with the same email exist. Email is already validated by the form
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
        serializer = self.serializer_class(data=request.data, context={'request': request})
        val = serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']

        if user.is_active:
            token, created = Token.objects.get_or_create(user=user)
            return Response({'token': token.key})
        else:
            return Response({'error': 'Please verify your account with the confirmation email'})
