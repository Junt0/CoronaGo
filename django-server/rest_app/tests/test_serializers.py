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


class TestUserInteractionSerializer(APITestCase):
    def setUp(self) -> None:
        self.test_user1 = User.objects.create(first_name="name1", last_name="name1last", username="username1",
                                              email="test1@gmail.com")
        self.test_prof1 = Profile.objects.create(user=self.test_user1, risk=0.2)
        self.meet_time = timezone.now()
        self.test_user2 = User.objects.create(first_name="name2", last_name="name2last", username="username2",
                                              email="test2@gmail.com")
        self.test_prof2 = Profile.objects.create(user=self.test_user2, risk=0.4)

        self.interaction = UserInteraction.objects.create(meet_time=self.meet_time)
        self.interaction.add_participants([self.test_prof1, self.test_prof2])

    def test_serialization(self):
        serializer = UserInteractionSerializer(self.interaction)

        data = serializer.data

        self.assertTrue('unique_id' in data.keys())
        self.assertTrue('meet_time' in data.keys())
        self.assertTrue('end_time' in data.keys())
        self.assertTrue('creator' in data.keys())
        self.assertEquals(len(data['participants']), 2)
