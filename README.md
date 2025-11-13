## Flow of Request

```
Client (Browser)
    |
    | HTTPS :443
    ↓
[nginx] ──proxy──> [wordpress] ──SQL :3306──> [mariadb]
    ↑                   |                         |
    |                   |                         |
    └───────────────────┴─────────────────────────┘
           (inception_network)
```

---

## Inception — Docker & docker-compose primer

This README explains how Docker and docker-compose work, the difference between running an image with and without docker-compose, and the benefits of Docker compared to virtual machines. It also contains exercises the evaluated student must complete: a short explanation of a docker network and steps to log into the database used in this project.

### Quick repo facts (from current compose file)
- Main services: `mariadb`, `wordpress`, `nginx`
- Compose network: `inception_network`
- Secrets are used for database and WordPress passwords (see `secrets/`)

## 1) How Docker works (simple)
- Docker packages an application and its dependencies into a container image. An image is a read-only template (layers). A running container is a lightweight, isolated process created from an image.
- Containers share the host OS kernel but have isolated filesystem, processes, and networking namespaces.

Inputs/outputs (contract):
- Input: a Docker image (or Dockerfile) and runtime configuration (ports, volumes, env, secrets)
- Output: running containers that provide the service(s) described by the image(s)
- Error modes: image build failures, missing secrets/env, port conflicts

Edge cases to consider: missing volumes, secret not provided, port already in use, container crash loops.

## 2) How docker-compose works (simple)
- `docker-compose` (or `docker compose`) reads a YAML file (docker-compose.yml) that declares multiple services, networks, and volumes.
- It automates creating a dedicated network, starting containers in the right order (via `depends_on`), mounting volumes, and injecting env/secrets.
- Compose is a declarative way to run multi-container apps locally or for simple deployments.

## 3) Difference: using an image without docker-compose vs with docker-compose
- Without docker-compose (single-container, manual): you use `docker pull` and `docker run` to start containers. You must manually connect containers to networks, mount volumes, pass env vars, and manage start order.
- With docker-compose (multi-container orchestration): you describe all services, networks, and volumes in one file and bring all services up/down together using `docker-compose up` / `docker compose up`.

When to use which:
- Use `docker run` for quick single-container tests or debugging.
- Use `docker-compose` for local multi-service development and reproducible stacks.

## 4) Benefits of Docker vs virtual machines (VMs)
- Lightweight: containers share the host kernel — start in seconds and use less memory/CPU.
- Fast builds and smaller storage via layered images and caching.
- Better portability: images bundle app + dependencies and run on any compatible Docker host.
- Higher density: more containers per host vs VMs per host.
- However, VMs offer stronger isolation (separate kernels) and may be required for different OS kernels.

## 5) docker-network (student must explain)
Task for the evaluated student: in one or two sentences, explain what a Docker network is and why it is useful.

Expected short answer (example):
- "A Docker network is a virtual network namespace that allows containers to communicate with each other and the host. It provides isolation and service discovery (containers on the same user-defined network can reach each other by name)."

## 6) How to login into the database (practical steps)
The project uses a `mariadb` service defined in `srcs/docker-compose.yml`. Below are safe and commonly used commands you can run from the project's root (WSL shell). Replace `docker-compose` with `docker compose` if you use the Docker CLI V2.

Interactive login (recommended):
```sh
# Start the stack (if not already running)
docker-compose up -d

# Open an interactive mysql client session as root (it will prompt for the password):
docker-compose exec mariadb mysql -u root -p
```

When prompted, paste the root password. This project stores secrets in `secrets/` and Compose mounts them into the container (commonly at `/run/secrets/<name>`).

Non-interactive login using the mounted secret (careful with history/logs):
```sh
# Run mysql client and pass the secret content directly (runs the command non-interactively):
docker-compose exec mariadb sh -c "mysql -u root -p$(cat /run/secrets/db_root_password)"
```

Open a shell inside the container then run mysql (useful to inspect files):
```sh
docker-compose exec mariadb sh
# then inside container
mysql -u root -p
```

Extra: using the `mysql` client from the host by connecting to the container's exposed port (not recommended here — this compose file does not publish the DB port):
```sh
# Example only: if the DB port were published (e.g. 3306:3306), you could run:
mysql -h 127.0.0.1 -P 3306 -u root -p
```

Commands to inspect network and containers (verification):
```sh
# List containers
docker-compose ps

# List Docker networks and find `inception_network`
docker network ls

# Inspect the compose-created network
docker network inspect inception_network
```

## 7) Evaluation checklist for the student
1. Provide a one- or two-sentence explanation of what a Docker network is (see section 5).
2. Show the exact commands you would run to login to the database of this project and explain any password source (interactive prompt, secrets at `/run/secrets/`).
3. Demonstrate (or explain) how to verify the network exists (e.g., `docker network ls` and `docker network inspect inception_network`).

## Notes & hints
- This repository uses Docker secrets declared in `docker-compose.yml`. Secrets are mounted inside containers at `/run/secrets/<secret_name>`.
- Use `docker compose` (no hyphen) if you have the Docker CLI v2; otherwise `docker-compose` works if installed.
- Commands above are written for a WSL shell (the repo was tested with Linux paths for bound volumes).

---
