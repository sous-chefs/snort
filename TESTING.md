# Testing

Use Cinc Workstation or Chef Workstation with Docker available.

```shell
chef install Policyfile.rb
cookstyle
chef exec rspec
KITCHEN_LOCAL_YAML=kitchen.dokken.yml chef exec kitchen test default-ubuntu-2404 --destroy=always
KITCHEN_LOCAL_YAML=kitchen.dokken.yml chef exec kitchen test remove-ubuntu-2404 --destroy=always
```

The default suite performs two converges and requires zero changes on the second.
It checks version, configuration, community rules, a running non-root service and
an alert from a synthetic offline packet. Removal checks unchanged owned artifacts and proves that operator files and logs survive.
Kitchen and CI cover the same suite/platform combinations. Do not run the capture
fixture on a production host or use host networking for the containers.
