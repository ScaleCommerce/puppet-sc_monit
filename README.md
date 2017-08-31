# sc_monit

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sc_monit](#setup)
    * [What sc_monit affects](#what-sc_monit-affects)
    * [Beginning with sc_monit](#beginning-with-sc_monit)
4. [Usage - Configuration options and additional functionality](#usage)

## Overview

ScaleCommerce Wrapper Module for sbitio-monit module. Manages Supervisord.

## Module Description

This module uses hiera to configure supervisord config for monit.

## Setup

### What sc_monit affects

* monit
* supervisord


### Beginning with sc_monit

You will need a working hiera-Setup (https://docs.puppetlabs.com/hiera/3.1/complete_example.html).

Check out our solution for Puppet-Hiera-Roles (https://github.com/ScaleCommerce/puppet-hiera-roles).

## Usage:

Put this into your node.yaml or role.yaml.

``` 
---
classes:
  - sc_monit
  
```

