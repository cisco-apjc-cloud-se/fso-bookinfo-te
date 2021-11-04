terraform {
  required_providers {
    thousandeyes = {
    #   source = "william20111/thousandeyes"
      source = "cgascoig/cgascoig/thousandeyes"   # this is a custom build of the william20111/thousandeyes provider with a bug fixed (see https://github.com/william20111/terraform-provider-thousandeyes/issues/59)
      version = "0.6.0"
    }
  }
}

provider "thousandeyes" {
  token = var.te_token
}


locals {
  http_tests = {
    "Bookinfo Normal" = {
      // server = "64.104.255.140"
      url = "http://64.104.255.140:8080/productpage?u=normal"
    },
    "Bookinfo Test" = {
      // server = "64.104.255.140"
      url = "http://64.104.255.140:8080/productpage?u=test"
    }
  }
}


data "thousandeyes_agent" "agents" {
  for_each = toset(var.agent_list)
  agent_name  = each.key
}

//
// locals {
//
//     # Add ping tests here:
//     icmp_tests = {
//         "ACI Fabric (VLAN28)" = {
//             server = "10.67.28.129"
//         },
//         "CECLAB AD/DNS" = {
//             server = "10.67.28.130"
//         },
//         "Google DNS 1" = {
//             server = "8.8.8.8"
//         },
//         "Google DNS 2" = {
//             server = "8.8.4.4"
//         },
//         "mel-lab-gw-1" = {
//             server = "10.67.17.2"
//         },
//         "mel-lab-gw-2" = {
//             server = "10.67.17.3"
//         },
//     }
//
//     # Add TCP connection tests here:
//     tcp_tests = {
//         "apic-1 (HTTPS)" = {
//             server = "10.67.29.51"
//             port = 443
//         },
//         "apic-2 (HTTPS)" = {
//             server = "10.67.29.52"
//             port = 443
//         },
//         "apic-3 (HTTPS)" = {
//             server = "10.67.29.53"
//             port = 443
//         },
//         "cg-linux-1 (SSH)" = {
//             server = "10.67.28.135"
//             port = 22
//         },
//         "cg-win-1 (RDP)" = {
//             server = "10.67.28.161"
//             port = 3389
//         },
//         "mel-dc-ng-vcenter (HTTPS)" = {
//             server = "10.67.17.125"
//             port = 443
//         },
//
//     }
// }

resource "thousandeyes_http_server" "http_tests" {
  for_each = local.http_tests

  test_name = "Web - ${each.key}"
  interval = 60
  url = each.value.url

  content_regex = ".*"

  network_measurements = 0
  mtu_measurements = 0
  bandwidth_measurements = 0
  bgp_measurements = 0
  use_public_bgp = 0
  num_path_traces = 0

  dynamic "agents" {
    for_each = toset(var.agent_list)
    content {
      agent_id = data.thousandeyes_agent.agents[agents.key].agent_id
    }
  }

  // agents {
  //     agent_id = data.thousandeyes_agent.agent.agent_id
  // }
}

// resource "thousandeyes_agent_to_server" "icmp_tests" {
//   for_each = local.icmp_tests
//
//   test_name = "Ping ${each.key}"
//   interval = 60
//   server = each.value.server
//   agents {
//       agent_id = data.thousandeyes_agent.agent.agent_id
//   }
//
//   protocol = "ICMP"
//
//   network_measurements = 1
//   mtu_measurements = 0
//   bandwidth_measurements = 0
//   bgp_measurements = 1
//   use_public_bgp = 1
//
//   // alert_rules {
//   //   rule_id = 1575407
//   // }
//   //
//   // alert_rules {
//   //   rule_id = 1575406
//   // }
// }

// resource "thousandeyes_agent_to_server" "tcp_tests" {
//   for_each = local.tcp_tests
//
//   test_name = "Connect to ${each.key}"
//   interval = 600
//   server = each.value.server
//   agents {
//       agent_id = data.thousandeyes_agent.agent.agent_id
//   }
//
//   protocol = "TCP"
//   port = each.value.port
//
//   network_measurements = 1
//   mtu_measurements = 0
//   bandwidth_measurements = 0
//   bgp_measurements = 0
//   use_public_bgp = 0
//
//   alert_rules {
//     rule_id = 1575407
//   }
//
//   alert_rules {
//     rule_id = 1575406
//   }
// }
