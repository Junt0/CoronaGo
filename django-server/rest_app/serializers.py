from django.contrib.auth.models import User
from rest_framework import serializers

from rest_app.models import Profile, UserInteraction


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'email')


class UserSignupSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'email', 'password')


class ProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Profile
        fields = ['user', 'risk']


class UserInteractionSerializer(serializers.ModelSerializer):
    participants = ProfileSerializer(many=True)
    creator = ProfileSerializer()

    class Meta:
        model = UserInteraction
        fields = ['unique_id', 'meet_time', 'end_time', 'creator', 'participants']
