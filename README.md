![onaka](./artwork/logo.png)

開発するならこんな感じ。

```shell-session
docker-compose -f ./docker-compose.dev.yml up -d
bundle exec rake db:setup
```

本番だとこんな感じ。

```shell-session
docker-compose up -d
docker-compose run --rm app rake db:setup
```
