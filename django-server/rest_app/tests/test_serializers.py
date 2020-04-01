from django.contrib.auth.models import User
from django.utils import timezone
from rest_framework.test import APITestCase

from rest_app.models import Profile, UserInteraction
from rest_app.serializers import UserSerializer, UserInteractionSerializer, ProfileSerializer
from collections import OrderedDict
from decimal import Decimal


class TestUserSerializer(APITestCase):
    def setUp(self) -> None:
        self.test_user = User(username="username", email="someemail@gmail.com", password="plaintext")

    def test_serialization(self):
        serializer = UserSerializer(self.test_user)
        actual_data = serializer.data

        expected_data = {
            'username': self.test_user.username,
            'email': self.test_user.email,
        }
        self.assertEquals(expected_data, actual_data)


class TestProfileSerializer(APITestCase):
    def setUp(self) -> None:
        self.user = User.objects.create(first_name="name1", last_name="name1last", username="username1",
                                        email="test1@gmail.com")
        self.user_prof = Profile.objects.create(user=self.user, risk=0.2)

    def test_serialization(self):
        serializer = ProfileSerializer(self.user_prof)
        actual_data = serializer.data
        user = OrderedDict({
            'username': self.user.username,
            'email': self.user.email,
        })

        expected_data = {
            'user': user,
            'risk': '0.2000'
        }
        self.assertEquals(expected_data, actual_data)

