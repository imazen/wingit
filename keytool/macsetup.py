from setuptools import setup

APP = ['keytool.py']
OPTIONS = {}

setup(
    app=APP,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)