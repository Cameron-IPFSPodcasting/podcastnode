### Build Stage
FROM python:slim-buster AS build

ARG IPFSGO=v0.13.0
ARG TARGETARCH

WORKDIR /ipfs-podcasting

RUN apt-get update; \
    apt-get install -y --no-install-recommends wget \
    && wget -q https://dist.ipfs.io/go-ipfs/${IPFSGO}/go-ipfs_${IPFSGO}_linux-$TARGETARCH.tar.gz \
    && wget -q https://dist.ipfs.io/go-ipfs/${IPFSGO}/go-ipfs_${IPFSGO}_linux-$TARGETARCH.tar.gz.sha512 \
    && cat ./go-ipfs_${IPFSGO}_linux-$TARGETARCH.tar.gz.sha512 | sha512sum -c \
    && tar xzf go-ipfs_${IPFSGO}_linux-$TARGETARCH.tar.gz \
    && cp go-ipfs/ipfs /usr/local/bin \
    && rm -rf go-ipfs_${IPFSGO}_linux-$TARGETARCH.tar.gz go-ipfs ./go-ipfs_${IPFSGO}_linux-$TARGETARCH.tar.gz.sha512 \
    && rm -rf /var/lib/apt/lists/*

### Bundle Stage
FROM python:slim-buster AS bundle

ENV IPFS_PATH=/ipfs-podcasting/ipfs
ARG USERID=1000
WORKDIR /ipfs-podcasting

RUN apt-get update; \
    apt-get install -y --no-install-recommends wget net-tools procps \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir requests thread6 bottle beaker \
    && mkdir /ipfs-podcasting/cfg /ipfs-podcasting/ipfs \
    && chown -R ${USERID}:${USERID} /ipfs-podcasting

COPY --from=build /usr/local/bin/ipfs /usr/local/bin/
COPY *.py *.png ./

USER ${USERID}
ENTRYPOINT ["python", "ipfspodcastnode.py"]
EXPOSE 4001/tcp 5001/tcp 8675/tcp
