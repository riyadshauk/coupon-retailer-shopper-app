# Use an official Swift runtime as a parent image (see: https://hub.docker.com/_/swift/)
FROM swift:4.2

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in build-app.sh
RUN bash build-app.sh

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Define environment variable
# ENV NAME WebServer

# Set proxy server, replace host:port with values for your servers
# ENV http_proxy http://wpad/wpad.dat
# ENV https_proxy http://wpad/wpad.dat

# Run app when the container launches
# CMD ["vapor", "run"]
CMD ["swift", "run", "Run", "--hostname", "0.0.0.0", "--port", "8080"]