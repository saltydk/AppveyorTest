curl -s https://cloudbox.works/scripts/dep.sh | sudo -H sh &> /dev/null
curl -s https://cloudbox.works/scripts/repo.sh | bash &> /dev/null

echo "=========================="
echo ""
echo "Community Branch: $APPVEYOR_REPO_BRANCH"
echo ""
cd ${COMMUNITY_PATH}
cp -n defaults/ansible.cfg.default ansible.cfg
cp -n defaults/settings.yml.default settings.yml
sudo ansible-playbook community.yml --syntax-check
RC=$?; [ $RC -eq 0 ] || exit $RC;

echo ""
echo "=========================="
echo ""
echo "Cloudbox Branch: $CLOUDBOX_BRANCH"
echo ""
cd ${CLOUDBOX_PATH}
rm settings.yml accounts.yml adv_settings.yml
git checkout $CLOUDBOX_BRANCH &> /dev/null
sudo ansible-playbook cloudbox.yml --syntax-check
sudo ansible-playbook cloudbox.yml --tags core \
    --skip-tags sanity_check,settings \
    --skip-tags kernel,hetzner,shell,rclone,system,motd,nvidia,mounts,scripts \
    --extra-vars '{"continuous_integration":true}' \
    &> /dev/null
sudo docker login -u $DOCKER_USER -p $DOCKER_PWD

echo ""
echo "=========================="
echo ""
echo "Community Roles:"
echo ""
cd ${COMMUNITY_PATH}

echo --------------------------
echo ""
echo Running Tag: ${TAG}
sudo ansible-playbook community.yml --tags ${TAG} \
    --skip-tags sanity_check,settings \
    --extra-vars '{"continuous_integration":true}'
RC=$?; [ $RC -eq 0 ] || exit $RC;
echo ""
