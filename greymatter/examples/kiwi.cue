package examples

import (
	gsl "greymatter.io/gsl/v1"

	"examples.module/greymatter:globals"
)


Kiwi: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Kiwi.#NewContext & globals

	// name must follow the pattern namespace/name
	name:          "kiwi"
	display_name:  "Examples Kiwi"
	version:       "v1.0.0"
	description:   "EDIT ME"
	api_endpoint:              "https://\(context.globals.edge_host)/services/\(context.globals.namespace)/\(name)/"
	api_spec_endpoint:         "https://\(context.globals.edge_host)/services/\(context.globals.namespace)/\(name)/"
	
	business_impact:           "low"
	owner: "Examples"
	capability: ""
	health_options: {
		tls: gsl.#TLSUpstream
	}
	// Kiwi -> ingress to your container
	ingress: {
		(name): {
			gsl.#HTTPListener
			gsl.#TLSListener
			
			//  NOTE: this must be filled out by a user. Impersonation allows other services to act on the behalf of identities
			//  inside the system. Please uncomment if you wish to enable impersonation. If the servers list if left empty,
			//  all traffic will be blocked.
				filters: [
			//    gsl.#ImpersonationFilter & {
			// 		#options: {
			// 			servers: "CN=alec.holmes,OU=Engineering,O=Decipher Technology Studios,L=Alexandria,ST=Virginia,C=US"
			// 			caseSensitive: false
			// 		}
			//    }
					gsl.#FaultInjectionFilter & {
						#options: {
							abort: {
								// header_abort: {} // Headers can also specify the percentage of requests to fail, capped by the below value with the x-envoy-fault-abort-request-percentage header
								percentage: {
									numerator: 50
									denominator: "HUNDRED"
								}
								http_status: 404
							}
						}
					}
				]
			routes: {
				"/": {
					
					upstreams: {
						"local": {
							gsl.#Upstream
							
							instances: [
								{
									host: "127.0.0.1"
									port: 9090
								},
							]
						}
					}
				}
			}
		}
	}


	
	// Edge config for the Kiwi service.
	// These configs are REQUIRED for your service to be accessible
	// outside your cluster/mesh.
	edge: {
		edge_name: "edge"
		routes: "/services/\(context.globals.namespace)/\(name)": {
			prefix_rewrite: "/"
			upstreams: (name): {
				gsl.#Upstream
				namespace: context.globals.namespace
				gsl.#TLSUpstream
			}
		}
	}
	
}

exports: "kiwi": Kiwi
