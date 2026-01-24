# GitHub Repo Koruma Rehberi

**beaver-iot-docker** ve diğer rifatsekerariot Beaver repolarını korumak için önerilen ayarlar.

---

## 1. Bu repoda eklenen dosyalar

- **SECURITY.md** — Güvenlik bildirimi.
- **.github/dependabot.yml** — Docker base image + GitHub Actions güncellemeleri.
- **.github/PULL_REQUEST_TEMPLATE.md** — PR şablonu.
- **CODEOWNERS** — `@rifatsekerariot`.

---

## 2. GitHub’da uygulayın

### Branch protection (`main`)

1. [beaver-iot-docker](https://github.com/rifatsekerariot/beaver-iot-docker) → **Settings** → **Branches**.
2. **Add branch protection rule** → **Branch name pattern:** `main`.
3. **Require a pull request before merging** → açın.
4. **Allow force pushes** → kapalı.
5. **Allow deletion** → kapalı.
6. **Create** / **Save**.

### Dependabot

- **Settings** → **Code security and analysis** → **Dependabot alerts** (ve isteğe bağlı **security updates**) → **Enable**.

---

## 3. Geliştirme akışı

- `main`’e doğrudan push yok; değişiklikler **branch → PR → merge** ile yapılır.

Diğer repolar (integrations, web, blueprint) için de aynı branch protection mantığı uygulanabilir. Detaylı adımlar: [beaver-iot-integrations GITHUB_REPO_PROTECTION.md](https://github.com/rifatsekerariot/beaver-iot-integrations/blob/main/GITHUB_REPO_PROTECTION.md).
