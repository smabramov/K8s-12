# «Установка Kubernetes»- Абрамов Сергей

### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развёрнутые ВМ с ОС Ubuntu 20.04-lts.


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция по установке kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
2. [Документация kubespray](https://kubespray.io/).

-----

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

### Решение

Команды используемые для поднятия кластера kubespray.

```
sudo apt update  -y
sudo apt install git -y
sudo apt install python3 -y
sudo apt install python3-pip -y
sudo apt install python3.10-venv -y
git clone https://github.com/kubernetes-sigs/kubespray
cd kubespray
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
pip install -r requirements.txt

cp -rfp inventory/sample inventory/mycluster

declare -a IPS=()
pip3 install ruamel.yaml
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v &

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chmod $(id -u):$(id -g) $HOME/.kube/config

```
Терраформ

[scr](https://github.com/smabramov/K8s-12/tree/7c19bf8eac8c5a6c852c9e4a138fe98394d64a05/scr)

![terrafom](https://github.com/smabramov/K8s-12/blob/7c19bf8eac8c5a6c852c9e4a138fe98394d64a05/png/terraform.png)

Сконфигурировал файл инвентаря hosts.yaml и запустил playbook

![kubespray](https://github.com/smabramov/K8s-12/blob/7c19bf8eac8c5a6c852c9e4a138fe98394d64a05/png/kubespray.png)

![nodes](https://github.com/smabramov/K8s-12/blob/7c19bf8eac8c5a6c852c9e4a138fe98394d64a05/png/nodes.png)


## Дополнительные задания (со звёздочкой)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.** Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой необязательные к выполнению и не повлияют на получение зачёта по этому домашнему заданию. 

------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA.
2. Использовать нечётное количество Master-node.
3. Для cluster ip использовать keepalived или другой способ.

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl get nodes`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
