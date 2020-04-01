from django.test import TestCase
from django.contrib.auth.models import User
from django.urls import reverse

from rest_app import exceptions
from rest_app.models import Profile, UserInteraction
from django.utils import timezone
import pytz


class ProfileTests(TestCase):
    def setUp(self):
        self.test_user = User.objects.create(username="test username", password="test_pass", email="test@gmail.com")
        self.test_profile = Profile.objects.create(user=self.test_user, risk=0.1)
        self.test_user2 = User.objects.create(first_name="name2", last_name="name2last", username="username2",
                                              email="test2@gmail.com")
        self.test_user2 = Profile.objects.create(user=self.test_user2, risk=0.4)

    def test_user_profile_creation(self):
        self.assertEqual(self.test_profile.user, self.test_user)
        self.assertEqual(self.test_profile.risk, 0.1)
        self.assertEqual(self.test_profile.user.is_active, False)

    def test_has_corona(self):
        self.test_profile.risk = 0
        self.assertFalse(self.test_profile.has_corona())

        self.test_profile.risk = 1
        self.assertTrue(self.test_profile.has_corona())

        self.test_profile.risk = 0.4
        self.assertFalse(self.test_profile.has_corona())

    def test_email_sent(self):
        from django.core import mail
        self.test_profile.send_verification_email()
        self.assertEqual(len(mail.outbox), 1)
        self.assertEqual(mail.outbox[0].to, [self.test_profile.user.email])

    def test_brand_new(self):
        new_user = User.objects.create(username="test3", password="hasdf", email="testemail@test.com")
        new_prof = Profile.brand_new(user=new_user)

        self.assertEquals(new_prof.user, new_user)
        self.assertEquals(new_prof.risk, 0)

    def test_get_interactions(self):
        interaction = UserInteraction.start(self.test_profile)
        interaction.add_participants([self.test_profile, self.test_user2])

        query_result = [result for result in self.test_profile.interactions]

        self.assertEquals([interaction], query_result)

    def test_get_interactions_none(self):
        meet_time = timezone.now()
        interaction = UserInteraction.objects.create(meet_time=meet_time)
        interaction.add_participants([])

        result = self.test_profile.interactions
        self.assertEquals(None, result)


    def test_has_no_running_interactions(self):
        interaction = UserInteraction.start(self.test_profile)
        interaction.add_participants([self.test_profile, self.test_user2])
        interaction.end()

        self.assertIsNotNone(self.test_profile.interactions)
        self.assertFalse(self.test_profile.has_running_interactions)

    def test_has_running_interactions(self):
        interaction = UserInteraction.start(self.test_profile)
        interaction.add_participants([self.test_profile, self.test_user2])

        self.assertIsNotNone(self.test_profile.interactions)
        self.assertTrue(self.test_profile.has_running_interactions)


class TestInteractionTests(TestCase):
    def setUp(self) -> None:
        self.test_user1 = User.objects.create(first_name="name1", last_name="name1last", username="username1",
                                              email="test1@gmail.com")
        self.test_user1 = Profile.objects.create(user=self.test_user1, risk=0.1)
        self.test_user2 = User.objects.create(first_name="name2", last_name="name2last", username="username2",
                                              email="test2@gmail.com")
        self.test_user2 = Profile.objects.create(user=self.test_user2, risk=0.4)

    def test_add_users_interaction(self):
        self.meet_time = timezone.now()
        self.interaction = UserInteraction.objects.create(meet_time=self.meet_time)
        self.interaction.add_participants([self.test_user1, self.test_user2])

        user_count = self.interaction.participants.all().count()
        self.assertEqual(user_count, 2)
