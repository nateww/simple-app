## Deploying app to Aptible

##### Prerequisites

* An active aptible account login with proper credentials.
* The aptible cli tool installed (MacOS - `brew cask install aptible`)
* This git repo
* 30-60 minutes of time

### Aptible configuration

We need to follow a number of steps to deploy and use this app in Aptible

* [Create Aptible Environment](#create-aptible-environment)
* [Deploying the application](#deploying-the-application-in-aptible)
* [Route traffic to application](#routing-web-traffic-to-the-running-application)
* [Test application](#test-access-to-application)

#### Create Aptible Environment

First, the environment must be created.  For purposes of training, the
cheapest environment is a non-dedicated (shared tenancy) environment,
so on the Aptible console, I created a new Environment by choosing the
`Create Environment` link in the menu on the left.

* Name: test-environment
* Tenancy: Shared
* Stack: shared-us-east-1-wat

Click on `Create Environment` to create the new environment.

The actual name of the environment is not super important, but should be
descriptive to others using the system, but the name will be referenced below.
Specifically, the environment name (`test-environment` above), will be
referred to as ENVIRONMENT (all-caps) below.

Note, it doesn't appear that the environment can be creatd from the CLI tools.

#### Creating Aptible App

On the command line, create a new Application in the new test environment,
by running the command below:
```
    aptible apps:create ruby-test --environment test-environment
```

The output of this will generate something similar to the following:
```
    App ruby-test created!
    Git Remote: git@beta.aptible.com:test-environment/ruby-test.git
```

You'll need to remember this remote and use it in the next step.  Similarly
to the environment name above, the name used is not critical, and will be
referenced as HANDLE (in all caps) below, to match the name given in the
Aptible documentation.

#### Deploying the application in Aptible

Aptible uses git hooks to build and deploy your application, so the
next step is to configure the repo to have aptible as a remote.  In the
current directory, run the following command, using the Git Remote returned
above.

```
    git remote add aptible git@HOST.aptible.com:ENVIRONMENT/HANDLE.git
```

Where HOST, ENVIRONMENT, and HANDLE are from above.

The next step is to push the contents of the repo to aptible, which will
cause the application (docker image) to get built, and deployed.

```
    git push -u aptible master
```

You should see a number of log lines generated, looking something like the
output of a docker build, and then lines showing the application is being
deployed.

```
Enumerating objects: 107, done.
Counting objects: 100% (107/107), done.
Delta compression using up to 12 threads
Compressing objects: 100% (92/92), done.
Writing objects: 100% (107/107), 22.79 KiB | 2.85 MiB/s, done.
Total 107 (delta 16), reused 0 (delta 0), pack-reused 0
remote: {:uplevel=>1}
remote: INFO: Authorizing...
remote: INFO: Initiating deploy...
remote: INFO: Deploying b3a703e2...
remote: 
remote: INFO: Pressing CTRL + C now will NOT interrupt this deploy
remote: INFO: (it will continue in the background)
...
remote: INFO -- : Successfully built d4ad0a3581b9
...
remote: INFO -- : a0bdfde68895: Pushed
...
remote: INFO -- : latest: digest: sha256:a178d6752153af00ff3f06656006c24bc94013bdfa02fb5ea66773735c725349 size: 2625
remote: INFO -- : Pulling from app-24208/13b5b5f0-2c4f-4390-ac25-703e58c2456c
remote: INFO -- : Digest: sha256:a178d6752153af00ff3f06656006c24bc94013bdfa02fb5ea66773735c725349
remote: INFO -- : Status: Image is up to date for dualstack-v2-registry-i-014ae90d485af97bd.aptible.in:46022/app-24208/13b5b5f0-2c4f-4390-ac25-703e58c2456c:latest
remote: INFO -- : Image app-24208/13b5b5f0-2c4f-4390-ac25-703e58c2456c successfully pushed to registry.
remote: INFO -- : STARTING: Register service cmd in API
remote: INFO -- : COMPLETED (after 1.3s): Register service cmd in API
remote: INFO -- : STARTING: Schedule service cmd
remote: INFO -- : COMPLETED (after 0.3s): Schedule service cmd
remote: INFO -- : STARTING: Create new release for service cmd
remote: INFO -- : COMPLETED (after 0.64s): Create new release for service cmd
remote: INFO -- : STARTING: Stop old app containers for service cmd
remote: INFO -- : COMPLETED (after 0.0s): Stop old app containers for service cmd
remote: INFO -- : STARTING: Start app containers for service cmd
remote: INFO -- : WAITING FOR: Start app containers for service cmd
...
remote: INFO -- : COMPLETED (after 0.09s): Commit app in API
remote: INFO -- : App deploy successful.
remote: INFO: Deploy succeeded.
To beta.aptible.com:test-environment/ruby-test.git
 * [new branch]      master -> master
Branch 'master' set up to track remote branch 'master' from 'aptible'.
```

For future deployments, you just need to push new deployments to aptible,
as setting the git remote is a one-time step.

#### Routing web traffic to the running application

Aptible calls this step exposing the web app to the internet.

First, we need to create an endpoint

```
    aptible endpoints:https:create --app ruby-test --default-domain --port=3000 cmd
```

* _--app_ : ruby-tesst (the HANDLE of the application as registered above)
* _--default-domain_ : Use the aptible hostname (no SSL required)
* _--port=3000_ : This is the port where the container is expecting traffic
* _cmd_ : Expose the service by running the CMD defined in the Dockerfile

After running the above, you should get output from the command, snippets
provided below:

```
INFO -- : Starting Vhost provision operation with ID: 22593331
INFO -- : Provisioning endpoint...
...
INFO -- : WAITING FOR: Register new http targets with endpoint app-24208.on-aptible.com, Register new https targets with endpoint app-24208.on-aptible.com
...
INFO -- : STARTING: Wait for Route 53 health to sync for endpoint app-24208.on-aptible.com
...
INFO -- : STARTING: Create ALIAS for endpoint app-24208.on-aptible.com
INFO -- : WAITING FOR: Create ALIAS for endpoint app-24208.on-aptible.com
...
INFO -- : Endpoint provision successful.
Id: 29954
Hostname: elb-shared-us-east-1-wat-29954.aptible.in
Status: provisioned
Type: https
Port: 3000
Internal: false
IP Whitelist: all traffic
Default Domain Enabled: true
Default Domain: app-24208.on-aptible.com
Managed TLS Enabled: false
Service: cmd
```

The application is now deployed, and should be accessible on port 80.

#### Test access to application

In your browser, connect to the application via HTTP

http://app-24208.on-aptible.com/

Next, try HTTPS

https://app-24208.on-aptible.com/

And, for grins, you can use curl.

```
    curl -sS https://app-24208.on-aptible.com/
```

Not covered is setting up SSL certificates to the sites, or discussions
of internal vs. external services (databases, etc...).

References:
- https://deploy-docs.aptible.com/docs/ruby-quickstart
- https://deploy-docs.aptible.com/docs/expose-web-app
- https://deploy-docs.aptible.com/docs/cli-endpoints-https-create
