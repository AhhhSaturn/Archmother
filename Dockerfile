FROM alpine:latest AS builder

RUN apk add --no-cache curl xz
RUN curl -L https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz | \
    tar -xJ -C /usr/local && \
    ln -s /usr/local/zig-x86_64-linux-0.16.0/zig /usr/local/bin/zig

WORKDIR /app

COPY build.zig build.zig.zon ./
COPY src/ src/

RUN zig build -Doptimize=ReleaseFast

FROM scratch

COPY --from=builder /app/zig-out/bin/Archmother /Archmother

CMD [ "/Archmother" ]
