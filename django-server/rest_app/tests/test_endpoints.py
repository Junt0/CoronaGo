import json
from decimal import Decimal

from django.contrib.auth.models import User
from django.test import Client
from django.urls import reverse
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient, APITestCase

from rest_app.models import Profile, UserInteraction
from rest_app.serializers import InteractionsLastModified, UserInteractionSerializer

"""def get_csrf_token(self):
client = RequestsClient()
# Obtain a CSRF token.
response = client.get('http://testserver/homepage/')
assert response.status_code == 200
self.csrftoken = response.cookies['csrftoken']"""


class TestAuthentication(APITestCase):
    def setUp(self) -> None:
        self.test_user = None
        self.test_profile = None

        self.client = Client(enforce_csrf_checks=True)

        self.setup_user()

    def setup_user(self):
        self.test_user = User.objects.create(username="testusername", email="test@gmail.com")
        self.test_user.set_password("test_pass")
        self.test_user.is_active = True
        self.test_user.save()
        self.test_profile = Profile.brand_new(user=self.test_user)

    def test_get_token_is_active(self):
        token_url = reverse('get_token')
        rq = {
            'username': self.test_user.username,
            'password': 'test_pass',
        }

        actual_token = Token.objects.get(user=self.test_user)
        response = self.client.post(token_url, rq)

        self.assertEquals(response.status_code, 200)
        self.assertEquals(actual_token.key, response.data['token'])

    def test_api_auth_signup_user_exists(self):
        # Test user already exists
        data = {
            'email': self.test_user.email,
            'username': self.test_user.username,
            'password': 'somepass1234',
        }
        url = reverse('signup')
        response = self.client.post(url, data=data)

        self.assertEquals(response.status_code, 403)

    def test_api_auth_signup_user_doesnt_exist(self):
        # Test user already exists
        data = {
            'email': 'test123@gmail.com',
            'username': 'newuser12',
            'password': 'somepassword',
        }
        url = reverse('signup')
        response = self.client.post(url, data=data)

        self.assertEquals(response.status_code, 200)

        user = User.objects.get(email=data['email'])
        profile = Profile.objects.get(user=user)
        self.assertIsNotNone(user)
        self.assertIsNotNone(profile)

        self.assertEquals(user.is_active, False)
        self.assertNotEqual(user.password, data['password'])

    def test_verification_email_link(self):
        # Test first visit
        self.test_user.is_active = False
        self.test_user.save()
        template_context = self.test_profile.send_verification_email()
        url = reverse('verify_email', kwargs={'uidb64': template_context['uid'], 'token': template_context['token']})
        response = self.client.get(url)
        self.assertEquals(response.status_code, 200)
        self.assertTrue("Thank you" in str(response.content))
        self.test_user = User.objects.get(username="testusername")
        self.assertTrue(self.test_user.is_active)

        # Test expires after visit
        response = self.client.get(url)
        self.assertEquals(response.status_code, 200)
        self.assertTrue("has expired" in str(response.content))

    def test_get_token(self):
        pass


class TestUserProfileEndpoints(APITestCase):
    def setUp(self) -> None:
        self.client = APIClient(enforce_csrf_checks=True)
        self.test_user = None
        self.user_token = None
        self.test_profile = None

        self.setup_user()

    def setup_user(self):
        self.test_user = User.objects.create(username="test username", email="test@gmail.com")
        self.test_user.set_password("test_pass")
        self.test_user.is_active = True
        self.test_user.save()
        self.test_profile = Profile.brand_new(user=self.test_user)

        self.user_token = Token.objects.get(user=self.test_user)

    def test_auth_required(self):
        url = reverse('request_profile')
        response = self.client.get(url)

        # 401 code means unauthorized
        self.assertEquals(response.status_code, 401)
        parsed = json.loads(response.content)
        self.assertEquals(
            parsed['detail'], "Authentication credentials were not provided.")

    def test_has_auth_not_verified(self):
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.user_token.key)

        self.test_user.is_active = False
        self.test_user.save()

        url = reverse('request_profile')
        response = self.client.get(url)
        self.assertEquals(response.status_code, 401)

    def test_get_profile_with_token(self):
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.user_token.key)
        self.test_user.is_active = True
        self.test_user.save()

        url = reverse('request_profile')
        response = self.client.get(url)
        self.assertEquals(response.status_code, 200)

    def test_get_profile_from_email(self):
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.user_token.key)
        self.test_user.is_active = True
        self.test_user.save()

        url = reverse('email_profile', kwargs={'username': self.test_user.username})
        response = self.client.get(url)
        parsed = json.loads(response.content)
        self.assertEquals(response.status_code, 200)
        self.assertEquals(float(Decimal(parsed['risk'])), self.test_profile.risk)
        self.assertEquals(parsed['user']['email'], self.test_user.email)
        self.assertEquals(parsed['user']['username'], self.test_user.username)


class TestInteractionEndpoints(APITestCase):
    def setUp(self) -> None:
        self.test_user = None
        self.test_profile = None

        self.test_user2 = None
        self.test_profile2 = None

        self.client = APIClient(enforce_csrf_checks=True)
        self.token = None

        self.setup_user()

    def setup_user(self):
        self.test_user = User.objects.create(username="testusername", email="test@gmail.com")
        self.test_user.set_password("test_pass")
        self.test_user.is_active = True
        self.test_user.save()
        self.test_profile = Profile.brand_new(user=self.test_user)
        self.token = Token.objects.get(user=self.test_user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.token.key)

    def setup_interaction_test(self):
        self.test_user2 = User.objects.create(username="blah", password="fake password", email="fake@email.com")
        self.test_user2.is_active = True
        self.test_user2.save()
        self.test_profile2 = Profile.brand_new(user=self.test_user2)
        self.test_profile2.save()
        self.token = Token.objects.get(user=self.test_user2)
        interaction = UserInteraction.start(creator=self.test_profile2)
        interaction.add_participants([self.test_profile])
        interaction.save()
        return interaction

    def test_auth_required(self):
        client = APIClient(enforce_csrf_checks=True)
        url = reverse('create_interaction')
        response = client.get(url)

        # 401 code means unauthorized
        self.assertEquals(response.status_code, 401)
        parsed = json.loads(response.content)
        self.assertEquals(parsed['detail'], "Authentication credentials were not provided.")

    def test_create_interaction_no_others(self):
        url = reverse('create_interaction')
        response = self.client.get(url)

        interaction = UserInteraction.objects.get(creator=self.test_profile)
        parsed = json.loads(response.content)

        self.assertEquals(parsed['interaction_code'],str(interaction.unique_id))

    def test_create_interaction_has_others(self):
        interaction = UserInteraction.start(creator=self.test_profile)
        self.assertTrue(self.test_profile.has_running_interactions)

        url = reverse('create_interaction')
        response = self.client.get(url)
        parsed = json.loads(response.content)
        self.assertEquals(response.status_code, 403)
        self.assertEquals(
            'You can only have one interaction running at a time', parsed['detail'])

    def test_join_interaction_no_others(self):
        # Sets up user with interaction
        new_user = User.objects.create(username="blah", password="fake password", email="fake@email.com")
        prof = Profile.brand_new(user=new_user)
        self.assertFalse(self.test_profile.has_running_interactions)

        interaction = UserInteraction.start(creator=prof)

        # Tests response that the user joined the interaction
        url = reverse('join_interaction', kwargs={'code': interaction.unique_id})
        response = self.client.get(url)
        parsed = json.loads(response.content)

        self.assertEquals(parsed['interaction_code'],str(interaction.unique_id))
        self.assertEquals(response.status_code, 200)

        # Tests user is added to interaction
        self.assertTrue(self.test_profile.has_running_interactions)

    def test_join_interaction_has_others(self):
        new_user = User.objects.create(
            username="blah", password="fake password", email="fake@email.com")
        prof = Profile.brand_new(user=new_user)

        # Asserts that the user is already in an interaction for the remainder of the test
        interaction = UserInteraction.start(creator=prof)
        interaction.add_participants([self.test_profile])
        self.assertTrue(self.test_profile.has_running_interactions)

        # Tests response that the was not allowed to join the interaction
        url = reverse('join_interaction', kwargs={'code': interaction.unique_id})
        response = self.client.get(url)
        parsed = json.loads(response.content)
        self.assertEquals(response.status_code, 403)
        self.assertEquals(parsed['detail'], 'You are only able to have one interaction running at a time')

    def test_end_interaction_is_creator(self):
        interaction = UserInteraction.start(creator=self.test_profile)
        interaction.add_participants([self.test_profile])
        self.assertFalse(interaction.has_ended)

        # Tests response that it ended the interaction
        url = reverse('end_interaction', kwargs={'code': interaction.unique_id})
        response = self.client.get(url)
        parsed = json.loads(response.content)
        self.assertEquals(response.status_code, 200)
        self.assertEquals(parsed['detail'], 'The interaction was ended')

        # Tests that the interaction was actually ended
        interaction = UserInteraction.objects.get(creator=self.test_profile)
        self.assertTrue(interaction.has_ended)

    def test_end_interaction_is_not_creator(self):
        new_user = User.objects.create(username="blah", password="fake password", email="fake@email.com")
        prof = Profile.brand_new(user=new_user)
        interaction = UserInteraction.start(creator=prof)
        interaction.add_participants([self.test_profile])
        self.assertFalse(interaction.has_ended)

        # Tests response that it ended the interaction
        url = reverse('end_interaction', kwargs={'code': interaction.unique_id})
        response = self.client.get(url)
        parsed = json.loads(response.content)
        self.assertEquals(response.status_code, 403)

        # Tests that the interaction was not ended
        interaction = UserInteraction.objects.get(creator=prof)
        self.assertFalse(interaction.has_ended)

    def test_get_interaction(self):
        interaction = self.setup_interaction_test()
        key = Token.objects.get(user=self.test_user2)
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {key}')

        url = reverse('get_interaction', kwargs={'code': interaction.unique_id})
        response = self.client.get(url)
        parsed = json.loads(response.content)
        self.assertEquals(response.status_code, 200)
        self.assertEquals(len(parsed.keys()), 5)
        self.assertEquals(parsed, UserInteractionSerializer(interaction).data)

    def test_get_interaction_not_in_interaction(self):
        interaction = self.setup_interaction_test()
        interaction.participants.remove(self.test_profile2)
        interaction.save()
        key = Token.objects.get(user=self.test_user2)
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {key}')

        url = reverse('get_interaction', kwargs={'code': interaction.unique_id})
        response = self.client.get(url)
        self.assertEquals(response.status_code, 401)

    def test_get_profiles_interactions(self):
        interaction = self.setup_interaction_test()
        key_string = f"Token {self.token}"
        self.client.credentials(HTTP_AUTHORIZATION=key_string)

        url = reverse('profile_interactions')
        response = self.client.get(url)
        parsed = json.loads(response.content)

        self.assertEquals(response.status_code, 200)
        self.assertEquals(len(parsed), 1)
        self.assertEquals(parsed, UserInteractionSerializer(self.test_profile2.interactions, many=True).data)

    def test_get_profiles_interactions_last_modified(self):
        interaction = self.setup_interaction_test()
        key_string = f"Token {self.token}"
        self.client.credentials(HTTP_AUTHORIZATION=key_string)

        url = reverse('last_modified')
        response = self.client.get(url)
        parsed = json.loads(response.content)

        self.assertEquals(response.status_code, 200)
        self.assertEquals(len(parsed), 1)
        self.assertEquals(parsed, InteractionsLastModified(self.test_profile2.interactions, many=True).data)
