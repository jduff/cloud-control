package :haproxy do
  description "HAProxy Load Balancer"
  apt 'haproxy'
  requires :stunnel
end

package :stunnel do
  apt 'stunnel'
end