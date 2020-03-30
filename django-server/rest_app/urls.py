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

    path('api/interaction/create/', views.GenerateInteraction.as_view()),
    path('api/interaction/join/<uuid:code>', views.JoinInteraction.as_view()),
    path('api/interaction/end/<uuid:code>', views.EndInteraction.as_view()),

    path('api/user/<int:id>', views.GetUserInfo.as_view(), name="info_self"),
    path('api/auth/', views.AuthGetToken.as_view(), name="get_token"),
    path('api/auth/signup/', views.AuthSignup.as_view(), name="signup"),
    re_path(r'^api/auth/confirm/(?P<uidb64>[0-9A-Za-z_\-]+)/(?P<token>[0-9A-Za-z]{1,13}-[0-9A-Za-z]{1,20})/$',
            views.VerifyAccount.as_view(), name='verify_email'),

]
