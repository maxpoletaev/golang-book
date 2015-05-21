from fabric.contrib.project import rsync_project
from fabric.api import *

env.user = 'poletaev'
env.hosts = ['zen.su']


@task
def deploy():
    local('bundle exec jekyll build')
    rsync_project(local_dir='build/', remote_dir='www/golang-book.ru')
