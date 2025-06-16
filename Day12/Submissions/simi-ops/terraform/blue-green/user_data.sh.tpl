#!/bin/bash
yum update -y
yum install -y httpd jq

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(echo $AVAILABILITY_ZONE | sed 's/[a-z]$//')

# Create health check endpoint
cat > /var/www/html/health <<EOF
OK
EOF

# Create index.html with environment information
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Zero-Downtime Deployment Demo - ${environment}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f0f0f0;
            color: #333;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-top: 5px solid ${color};
        }
        .environment {
            color: ${color};
            font-weight: bold;
            font-size: 24px;
        }
        .version {
            color: #666;
            font-style: italic;
        }
        .details {
            margin-top: 20px;
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Zero-Downtime Deployment Demo</h1>
        <h2>Environment: <span class="environment">${environment}</span></h2>
        <p class="version">Application Version: ${app_version}</p>
        
        <div class="details">
            <h3>Instance Details:</h3>
            <ul>
                <li><strong>Instance ID:</strong> $INSTANCE_ID</li>
                <li><strong>Region:</strong> $REGION</li>
                <li><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</li>
                <li><strong>Deployment Time:</strong> $(date)</li>
            </ul>
        </div>
        
        <p>This is a demonstration of zero-downtime deployment using Terraform with a blue/green deployment strategy.</p>
    </div>
</body>
</html>
EOF

# Set permissions
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health