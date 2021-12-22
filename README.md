# Starter Kit Boilerplate for Single Page Applications

This repo provides a starting point for any single page applications.

## Requirements
- Docker Compose
- MongoDB
- Dart SDK

## To run the server

1. Start your MongoDB server
2. Create a **.env** file under **spa_server** directory with a secret key and mongodb url:
```bash
SECRET_KEY=25BBD370-975D-4D45-8F5A-B3FA92155CCA
MONGO_URL=mongodb://127.0.0.1:27017/test
REDIS_HOST=localhost
REDIS_PORT=6379
SERVER_PORT=8080
```
3. Generate Env with `dart pub run build_runner build` command
4. Start Redis Server from docker file witj `docker-compose up -d`
5. Start server by hitting <key>**F5**</key> in VS Code or running `dart spa_server/bin/spa_server.dart`
 in your terminal
6. Visit **http://localhost:8080** in the browser and use Postman to perform the other api calls.

[See the full tutorial](https://youtu.be/ZKNKNxaliZQ).

# Support my work

I teach developers to build full-stack applications with Dart and Flutter. If you've found my content helpful and wish to support me in any way, please use the links below:

1. [Subscribe to the channel](https://youtube.com/c/CreativeBracket)
2. [Become a Patron](https://patreon.com/creativebracket)
3. [Follow me on Twitter](https://twitter.com/creativ_bracket)
4. [Grab me a coffee](https://ko-fi.com/creativebracket)

Many thanks 💙