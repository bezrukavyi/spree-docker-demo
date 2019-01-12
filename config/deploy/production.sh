source 'config/deploy/lib/deploy.sh'

RAILS_ENV='production'

# Deploy server app
deploy \
  --aws-access-key "$AWS_ACCESS_KEY_ID" \
  --aws-secret-key "$AWS_SECRET_ACCESS_KEY" \
  --region 'us-east-1' \
  --repo '252156031123.dkr.ecr.us-east-1.amazonaws.com/spreeproject/server_app' \
  --cluster 'spreeprojectProduction' \
  --service 'server-app-production' \
  --name 'spreeproject_server_app'

# Deploy worker app
deploy \
  --aws-access-key "$AWS_ACCESS_KEY_ID" \
  --aws-secret-key "$AWS_SECRET_ACCESS_KEY" \
  --region 'us-east-1' \
  --repo '252156031123.dkr.ecr.us-east-1.amazonaws.com/spreeproject/server_app' \
  --cluster 'spreeprojectProduction' \
  --service 'worker-app-production' \
  --name 'spreeproject_worker_app' \
  --skip-build true
