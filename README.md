# Elasticsearch Log Browser

*Elasticsearch Log Browser* is the app designed to browse logs stored in an Elasticsearch instance. Logs are Elasticsearch documents with a timestamp field. The app is written with [Flutter](https://flutter.dev/) SDK, so it can be run on both mobile platforms: Android and iOS.

<img height='800' width='auto' src='screenrecording.gif'/>

## Installation

For the time being the app is not available in the Google Play nor Apple App Store. To run the app you need to install:

1. [The Flutter env](https://flutter.dev/docs/get-started/install) 
2. [IDE](https://flutter.dev/docs/get-started/editor?tab=androidstudio)

Next:
- Download the project,
- Open it in your IDE,
- Install dependencies, 
- Run the app on a simulator or on a physical device.

## Using the app in the internet

If you want use the app in the internet you have to expose Elasticsearch data. For this, you can use commercial cloud solutions or use your own instance of a proxy server. Remember that logs can contain sensitive data and you shouldn't expose unsecured data to the internet. A proxy server may provide basic security measures such as:
- Encryption of communication (https)
- Basic authentication

[NGINX](https://www.nginx.com/) may be a good choice. 

You can check sample NGINX configuration [here](NGINX.md).


## Elasticsearch document requirements

The app expects [Elasticsearch documents](https://www.elastic.co/blog/what-is-an-elasticsearch-index) to contain:

1. Timestamp field 
    - Mandatory
    - Type: date

2. Severity 
    - Optional
    - Type: keyword
    - The value should be one of: *trace, info, debug, warning, error, fatal*

> If your logs don't contain the severity field, filtering by severity is not available in the app.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)