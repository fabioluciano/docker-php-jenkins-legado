directory=$(dirname $(realpath $0))
update='https://updates.jenkins-ci.org/latest/'
plugin_list=$(cat $directory'/plugins.txt')
plugins_location=/var/lib/jenkins/plugins

rm -rf $tmpdir

for plugin in $plugin_list; do
  echo 'Baixando o plugin '$plugin

  wget $update$plugin'.hpi' --quiet -P $plugins_location
  unzip -qq $plugins_location/$plugin.hpi -d $plugins_location/$plugin
done

