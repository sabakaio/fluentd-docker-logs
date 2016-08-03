#! /bin/bash

tdagent_pid=/run/td-agent/pid

function graceful_stop_tdagent() {
  echo "stop tdagent with pid $(cat ${tdagent_pid})"
  kill -SIGTERM $(cat ${tdagent_pid}) || exit 1
  exit 0
}

function tdagent_reload() {
  echo "config file changed. reloading td-agent"
  kill -SIGHUP $(cat ${tdagent_pid})
}

function start_inotify_waiter() {
  inotifywait -me moved_to /etc/td-agent | while read events; do tdagent_reload; done
}

trap graceful_stop_tdagent SIGTERM SIGINT

start_inotify_waiter &

td-agent --daemon ${tdagent_pid}

while :; do
  sleep 1
done
