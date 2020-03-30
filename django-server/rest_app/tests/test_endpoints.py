from django.contrib.auth.models import User
from django.test import TestCase, Client
from django.urls import reverse
from rest_framework.authtoken.models import Token
from rest_framework.test import APIRequestFactory, APIClient, APITestCase, RequestsClient
import requests
from rest_app.models import Profile


class TestThrottledAuth(APITestCase):
    def setUp(self) -> None:
        self.test_user = None
        self.client = RequestsClient()

        self.setup_user()
        self.get_csrf_token()

    def setup_user(self):
        self.test_user = User.objects.create(username="test username", email="test@gmail.com")
        self.test_user.set_password("test_pass")
        self.test_user.is_active = True
        self.test_user.save()

    def get_csrf_token(self):
        client = RequestsClient()

        # Obtain a CSRF token.
        home = reverse('home')
        response = client.get('https://testserver' + home)
        self.assertEquals(response.status_code, 200)
        self.csrftoken = response.cookies['csrftoken']

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
            'email': 'test@gmail.com',
            'username': 'test username',
            'password': 'password',
        }
        url = reverse('signup')
        response = self.client.post(url, data=data)

        self.assertEquals(response.status_code, 200)
        self.assertTrue('error' in response.data.keys())

    def test_api_auth_signup_user_exists(self):
        # Test user already exists
        data = {
            'email': 'test@gmail.com',
            'username': 'test username',
            'password': 'password',
        }
        url = reverse('signup')
        response = self.client.post(url, data=data)

        self.assertEquals(response.status_code, 200)
        self.assertTrue('error' in response.data.keys())

    def test_api_auth_signup_user_doesnt_exists(self):
        # Test user already exists
        data = {
            'email': 'test123@gmail.com',
            'username': 'new user',
            'password': 'some password',
        }
        url = reverse('signup')
        response = self.client.post(url, data=data)

        self.assertEquals(response.status_code, 200)
        self.assertTrue('success' in response.data.keys())

        user = User.objects.get(email=data['email'])
        profile = Profile.objects.get(user=user)
        self.assertIsNotNone(user)
        self.assertIsNotNone(profile)

        self.assertEquals(user.is_active, False)
        self.assertNotEqual(user.password, data['password'])
