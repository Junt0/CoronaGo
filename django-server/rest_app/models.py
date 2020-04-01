import uuid
from random import randint
from typing import List

from django.conf import settings
from django.contrib.sites.shortcuts import get_current_site
from django.core.mail import send_mail, EmailMessage
from django.db import models
from django.contrib.auth.models import User

# Create your models here.
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.template.loader import render_to_string
from django.utils import timezone
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode
from rest_framework.authtoken.models import Token

from rest_app import exceptions
from rest_app import tokens


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    risk = models.DecimalField(default=0.00, max_digits=4, decimal_places=4)

    @classmethod
    def brand_new(cls, user):
        prof = Profile.objects.create(user=user, risk=0)
        return prof

    def get_nodes(self):
        pass

    def has_corona(self):
        return self.risk == 1

    def send_verification_email(self):
        if not self.user.is_active:
            mail_subject = 'Activate Your CoronaGo Account'
            template_context = {
                'profile': self,
                'domain': settings.SITE_DOMAIN,
                'uid': urlsafe_base64_encode(force_bytes(self.user.pk)),
                'token': tokens.account_activation_token.make_token(self.user),
            }
            message = render_to_string('VerifyEmail.html', template_context)
            email = EmailMessage(
                mail_subject, message, to=[self.user.email]
            )
            email.send()
            return template_context

    @property
    def interactions(self):
        interaction = UserInteraction.objects.filter(participants__in=[self])
        if interaction.exists():
            return interaction
        return None


    @property
    def has_running_interactions(self):
        return UserInteraction.objects.filter(participants__in=[self], end_time=None).count() > 0


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        instance.is_active = False
        Token.objects.create(user=instance)


class UserInteraction(models.Model):
    unique_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    meet_time = models.DateTimeField(auto_now=True)
    end_time = models.DateTimeField(null=True)

    creator = models.ForeignKey(Profile, on_delete=models.SET_NULL, related_name="creator", null=True)
    participants = models.ManyToManyField(Profile, related_name="participants")

    @classmethod
    def start(cls, creator: Profile):
        # interactions are considered ended
        interaction = UserInteraction.objects.create(creator=creator)
        interaction.participants.add(creator)
        interaction.save()

        return interaction

    def add_participants(self, profiles: List[Profile]):
        self.participants.add(*profiles)
        self.save()

    def end(self):
        self.end_time = timezone.now()
        self.ended = True
        self.save()

    @property
    def has_ended(self):
        return self.end_time is not None
