from fabric.contrib.project import rsync_project
from fabric.api import local, env, task

env.user = 'poletaev'
env.hosts = ['zenwalker.ru']


@task
def deploy():
    local('bundle exec jekyll build')
    rsync_project(local_dir='build/', remote_dir='www/golang-book.ru')
