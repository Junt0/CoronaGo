from django.contrib.auth.models import User, Group
from rest_framework import serializers

from rest_app.models import Profile, UserInteraction


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'email')


class UserInteractionSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True)

    class Meta:
        model = UserInteraction
        fields = ['unique_id', 'meet_time', 'end_time', 'creator', 'participants']


class ProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Profile
        fields = ['user', 'risk']
