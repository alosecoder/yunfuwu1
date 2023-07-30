FROM alpine

RUN apk update && \
    apk add --no-cache sudo qemu-system-x86_64 xz dbus-x11 curl firefox-esr mate-system-monitor git xfce4 xfce4-terminal wget openssh iproute2

RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    curl -LO https://proot.gitlab.io/proot/bin/proot && \
    chmod 755 proot && \
    mv proot /bin && \
    tar -xvf v1.2.0.tar.gz

RUN adduser -D -s /bin/bash -G wheel luo && \
    echo 'luo:password' | chpasswd

RUN mkdir $HOME/.vnc && \
    echo 'luo' | vncpasswd -f > $HOME/.vnc/passwd && \
    chmod 600 $HOME/.vnc/passwd && \
    echo 'whoami' >> /luo.sh && \
    echo 'cd' >> /luo.sh && \
    echo "su -l -c 'vncserver :2000 -geometry 1280x800'" >> /luo.sh && \
    echo 'cd /noVNC-1.2.0' >> /luo.sh && \
    echo './utils/launch.sh --vnc localhost:7900 --listen 8900' >> /luo.sh && \
    chmod 755 /luo.sh

RUN echo "luo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

EXPOSE 22 8900

CMD ["/bin/sh", "-c", "service ssh start && /bin/sh /luo.sh"]
