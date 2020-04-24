"""CoronaGo URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.urls import path, re_path
from rest_framework import routers

from rest_app import views

router = routers.DefaultRouter()

urlpatterns = [
    path('', views.home, name="home"),
    path('api/interaction/<uuid:code>/', views.GetInteraction.as_view(), name="get_interaction"),
    path('api/interaction/create/', views.CreateInteraction.as_view(), name="create_interaction"),
    path('api/interaction/join/<uuid:code>/', views.JoinInteraction.as_view(), name="join_interaction"),
    path('api/interaction/end/<uuid:code>/', views.EndInteraction.as_view(), name='end_interaction'),
    

    path('api/user/', views.RequestProfile.as_view(), name="request_profile"),
    path('api/user/interactions/', views.GetProfileInteractions.as_view(), name="profile_interactions"),
    path('api/user/<str:username>/', views.GetProfile.as_view(), name="email_profile"),
    path('api/user/interactions/last-modified/', views.LastModifiedInteractions.as_view(), name="last_modified"),

    path('api/auth/', views.AuthGetToken.as_view(), name="get_token"),
    path('api/auth/signup/', views.AuthSignup.as_view(), name="signup"),
    re_path(r'^api/auth/confirm/(?P<uidb64>[0-9A-Za-z_\-]+)/(?P<token>[0-9A-Za-z]{1,13}-[0-9A-Za-z]{1,20})/$',
          views.VerifyAccount.as_view(), name='verify_email'),

]
