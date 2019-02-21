docker build --build-arg SHA="$(curl -s 'https://api.github.com/repos/OpenLiberty/boost/commits' | grep sha | head -1)" -t=testapp .
#docker run -p 4000:9080 testapp;
