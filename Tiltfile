
# from https://docs.tilt.dev/api.html#api.k8s_yaml
# "We will infer what (if any) of the k8s resources defined in your YAML correspond to Images defined elsewhere in your Tiltfile  (matching based on the DockerImage ref and on pod selectors)."
# to ensure images we build here are tagged/updated accordingly, we need to ensure we use labels
k8s_yaml(helm(
  './chart',
  # The release name, equivalent to helm --name
  name='dev',
  # The namespace to install in, equivalent to helm --namespace
  namespace='gamechanger',
  # The values file to substitute into the chart.
  values=['./dev.values.yaml'],
  ))

# load tilt extensions
# https://github.com/tilt-dev/tilt-extensions/tree/master/git_resource
load('ext://git_resource', 'git_checkout')

allow_k8s_contexts('mv-dev-0')
default_registry('registry.lab.boozallencsn.com/library')
build_dir = './build'
image_registry = "registry.lab.boozallencsn.com"
image_repo = "library/advana/gamechanger"

def gc_custom_build(image_name, dockerfile_path, deps):
  return 

## gc-web 
git_checkout("https://github.com/dod-advana/gamechanger-web#dev", 
  checkout_dir="{}/web".format(build_dir)
  )
custom_build("/library/advana/gamechanger/gamechanger-web", 
  "lima nerdctl build -t $EXPECTED_REF -f {build_dir}/web/Dockerfile.prod {build_dir}/web && lima nerdctl push $EXPECTED_REF".format(build_dir=build_dir),
  deps=["{}/web".format(build_dir)]
  )

## gc-data 
git_checkout("https://github.com/dod-advana/gamechanger-data.git#feature/fix-dockerfile-podman", 
  checkout_dir="{}/data".format(build_dir)
  )
custom_build(ref="gamechanger-data", 
  context="{}/data".format(build_dir), 
  dockerfile="{}/data/dev_tools/docker/k8s/rhel8.Dockerfile".format(build_dir)
  )

## gc-ml 
git_checkout("https://github.com/dod-advana/gamechanger-ml.git#dev", 
  checkout_dir="{}/ml".format(build_dir)
  )
custom_build(ref="gamechanger-ml", 
  context="{}/ml".format(build_dir), 
  dockerfile="{}/ml/gamechangerml/api/fastapi/cpu.mlapp.Dockerfile".format(build_dir)
  )

## gc-neo4j
git_checkout("https://github.com/dod-advana/gamechanger-neo4j-plugin.git#main", 
  checkout_dir="{}/neo4j".format(build_dir)
  )
custom_build(ref="neo4j", 
  context="{}/neo4j".format(build_dir), 
  dockerfile="{}/neo4j/docker/debian.Dockerfile".format(build_dir)
  )

## gc-crawlers
git_checkout("https://github.com/dod-advana/gamechanger-crawlers.git#feature/enable-packaging", 
  checkout_dir="{}/crawlers".format(build_dir)
  )
custom_build(ref="gamechanger-crawler", 
  context="{}/crawlers".format(build_dir), 
  dockerfile="{}/crawlers/Dockerfile".format(build_dir), 
  target='crawler-prod'
  )
