FROM debian

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y sudo qemu-kvm *zenhei* xz-utils dbus-x11 curl firefox-esr gnome-system-monitor mate-system-monitor git xfce4 xfce4-terminal tightvncserver wget openssh-server

RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    curl -LO https://proot.gitlab.io/proot/bin/proot && \
    chmod 755 proot && \
    mv proot /bin && \
    tar -xvf v1.2.0.tar.gz

RUN useradd -m -s /bin/bash -G sudo luo && \
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

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

EXPOSE 22 8900

CMD ["/bin/bash", "-c", "service ssh start && /bin/bash /luo.sh"]
