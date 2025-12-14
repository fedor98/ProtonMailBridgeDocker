# hydroxide

A third-party, open-source ProtonMail bridge. For power users only, designed to
run on a server.

hydroxide supports CardDAV, IMAP and SMTP.

Rationale:

* No GUI, only a CLI (so it runs in headless environments)
* Standard-compliant (we don't care about Microsoft Outlook)
* Fully open-source

Feel free to join the IRC channel: #emersion on Libera Chat.

## Docker workflow

This repository includes a Docker setup (see `Dockerfile`, `docker-compose.yml`
and `docker_shell_scripts/`) that keeps ProtonMail credentials out of the
Compose file. The flow is:

1. Build the image: `docker compose build`.
2. Start the long-running service: `docker compose up -d hydroxide`. If no
   credentials are present yet, the container will idle until you authenticate.
3. Authenticate once (can be repeated any time):
   * Enter the container shell (e.g. `docker compose exec -it hydroxide /bin/sh`).
   * Run `hydroxide auth <username>` inside the already running container and
     provide your ProtonMail password/2FA when prompted. The command prints the
     bridge password you will later configure in your mail client.

The cached bridge credentials are stored inside `/root/.config/hydroxide` (mount
this directory from the host if you want them to persist), so container restarts
do not require re-entering anything. If you change your ProtonMail password,
just run `hydroxide auth <username>` again inside the container; the service can
remain running the whole time.

## How does it work?

hydroxide is a server that translates standard protocols (SMTP, IMAP, CardDAV)
into ProtonMail API requests. It allows you to use your preferred e-mail clients
and `git-send-email` with ProtonMail.

    +-----------------+             +-------------+  ProtonMail  +--------------+
    |                 | IMAP, SMTP  |             |     API      |              |
    |  E-mail client  <------------->  hydroxide  <-------------->  ProtonMail  |
    |                 |             |             |              |              |
    +-----------------+             +-------------+              +--------------+

## Setup

### Go

hydroxide is implemented in Go. Head to [Go website](https://golang.org) for
setup information.

### Installing

Start by installing hydroxide:

```shell
git clone https://github.com/emersion/hydroxide.git
go build ./cmd/hydroxide
```

Then you'll need to login to ProtonMail via hydroxide, so that hydroxide can
retrieve e-mails from ProtonMail. You can do so with this command:

```shell
hydroxide auth <username>
```

Once you're logged in, a "bridge password" will be printed. Don't close your
terminal yet, as this password is not stored anywhere by hydroxide and will be
needed when configuring your e-mail client.

Your ProtonMail credentials are stored on disk encrypted with this bridge
password (a 32-byte random password generated when logging in).

## Usage

hydroxide can be used in multiple modes.

> Don't start hydroxide multiple times, instead you can use `hydroxide serve`.
> This requires ports 1025 (smtp), 1143 (imap), and 8080 (carddav).

### SMTP

To run hydroxide as an SMTP server:

```shell
hydroxide smtp
```

Once the bridge is started, you can configure your e-mail client with the
following settings:

* Hostname: `localhost`
* Port: 1025
* Security: none
* Username: your ProtonMail username
* Password: the bridge password (not your ProtonMail password)

### CardDAV

You must setup an HTTPS reverse proxy to forward requests to `hydroxide`.

```shell
hydroxide carddav
```

Tested on GNOME (Evolution) and Android (DAVDroid).

### IMAP

⚠️  **Warning**: IMAP support is work-in-progress. Here be dragons.

For now, it only supports unencrypted local connections.

```shell
hydroxide imap
```

## License

MIT
