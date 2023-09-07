FROM node:20.5-slim

# See https://crbug.com/795759
RUN apt-get update && apt-get install -yq libgconf-2-4

# https://linux.how2shout.com/install-google-chrome-on-debian-12-bookworm/
RUN apt install apt-transport-https curl -y
RUN curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /usr/share/keyrings/google-chrome.gpg >> /dev/null
RUN echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | tee /etc/apt/sources.list.d/google-chrome.list
RUN apt update
RUN apt install -y google-chrome-stable

# https://stackoverflow.com/questions/66403248/trying-to-yarn-add-a-private-github-repo-and-get-couldnt-find-the-binary-git
RUN apt install -y git

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

RUN yarn global add https://github.com/timoschwarzer/capture-website-cli

RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /usr/local/share/.config/yarn/global

USER pptruser

ENTRYPOINT ["dumb-init", "--"]
