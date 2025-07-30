#!/bin/bash

# Monitoring and Observability Setup Script for TaskFlow
# This script sets up Azure Application Insights monitoring and operational alarms

set -e

echo "🔍 TaskFlow Monitoring and Observability Setup"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Get Application Insights connection string
APP_INSIGHTS_NAME="taskflow-insights"
RESOURCE_GROUP="taskflow-rg"

echo "Step 1: Getting Application Insights connection string..."
CONNECTION_STRING=$(az monitor app-insights component show --app $APP_INSIGHTS_NAME --resource-group $RESOURCE_GROUP --query "connectionString" --output tsv)

if [ -n "$CONNECTION_STRING" ]; then
    print_status "SUCCESS" "Application Insights connection string retrieved"
else
    print_status "ERROR" "Failed to get Application Insights connection string"
    exit 1
fi

echo ""
echo "Step 2: Setting up monitoring for production environment..."
az webapp config appsettings set --name taskflow-app --resource-group $RESOURCE_GROUP --settings APPLICATIONINSIGHTS_CONNECTION_STRING="$CONNECTION_STRING"
print_status "SUCCESS" "Production monitoring configured"

echo ""
echo "Step 3: Setting up monitoring for staging environment..."
az webapp config appsettings set --name taskflow-staging --resource-group $RESOURCE_GROUP --settings APPLICATIONINSIGHTS_CONNECTION_STRING="$CONNECTION_STRING"
print_status "SUCCESS" "Staging monitoring configured"

echo ""
echo "Step 4: Creating operational alarms..."

# Create action group for alerts
echo "Creating action group for alerts..."
az monitor action-group create \
    --name "taskflow-alerts" \
    --resource-group $RESOURCE_GROUP \
    --short-name "taskflow" \
    --action email "admin@taskflow.com" "TaskFlow Admin"

# Create availability test for production
echo "Creating availability test for production..."
az monitor app-insights web-test create \
    --resource-group $RESOURCE_GROUP \
    --app $APP_INSIGHTS_NAME \
    --name "taskflow-production-health" \
    --url "https://taskflow-app.azurewebsites.net/health" \
    --location "East US" \
    --frequency 300 \
    --timeout 30 \
    --enabled true

# Create availability test for staging
echo "Creating availability test for staging..."
az monitor app-insights web-test create \
    --resource-group $RESOURCE_GROUP \
    --app $APP_INSIGHTS_NAME \
    --name "taskflow-staging-health" \
    --url "https://taskflow-staging.azurewebsites.net/health" \
    --location "East US" \
    --frequency 300 \
    --timeout 30 \
    --enabled true

print_status "SUCCESS" "Operational alarms configured"

echo ""
echo "Step 5: Setting up metric alerts..."

# Create alert for high response time
az monitor metrics alert create \
    --name "taskflow-high-response-time" \
    --resource-group $RESOURCE_GROUP \
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/$APP_INSIGHTS_NAME" \
    --condition "avg ResponseTime > 2000" \
    --window-size 5m \
    --evaluation-frequency 1m \
    --action "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/actionGroups/taskflow-alerts"

# Create alert for high error rate
az monitor metrics alert create \
    --name "taskflow-high-error-rate" \
    --resource-group $RESOURCE_GROUP \
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/$APP_INSIGHTS_NAME" \
    --condition "avg FailedRequests > 5" \
    --window-size 5m \
    --evaluation-frequency 1m \
    --action "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/actionGroups/taskflow-alerts"

print_status "SUCCESS" "Metric alerts configured"

echo ""
echo "Step 6: Creating monitoring dashboard..."

# Create dashboard JSON
cat > taskflow-dashboard.json << 'EOF'
{
    "lenses": {
        "0": {
            "order": 0,
            "parts": {
                "0": {
                    "position": {
                        "x": 0,
                        "y": 0,
                        "colSpan": 6,
                        "rowSpan": 4
                    },
                    "metadata": {
                        "inputs": [],
                        "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
                        "settings": {
                            "content": {
                                "Query": "requests\n| where timestamp > ago(1h)\n| summarize count() by bin(timestamp, 5m)\n| render timechart",
                                "PartTitle": "Request Rate (Last Hour)"
                            }
                        }
                    }
                },
                "1": {
                    "position": {
                        "x": 6,
                        "y": 0,
                        "colSpan": 6,
                        "rowSpan": 4
                    },
                    "metadata": {
                        "inputs": [],
                        "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
                        "settings": {
                            "content": {
                                "Query": "exceptions\n| where timestamp > ago(1h)\n| summarize count() by bin(timestamp, 5m)\n| render timechart",
                                "PartTitle": "Exception Rate (Last Hour)"
                            }
                        }
                    }
                }
            }
        }
    },
    "metadata": {
        "model": {
            "timeRange": {
                "value": {
                    "relative": {
                        "duration": 24,
                        "timeUnit": 1
                    }
                },
                "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
            },
            "filterLocale": {
                "value": "en-us"
            },
            "filters": {
                "value": {
                    "MsPortalFx_TimeRange": {
                        "model": {
                            "format": "utc",
                            "value": {
                                "relative": {
                                    "duration": 24,
                                    "timeUnit": 1
                                }
                            }
                        },
                        "displayCache": {
                            "name": "UTC Time",
                            "value": "Past 24 hours"
                        },
                        "filter": {
                            "type": "Microsoft.Portal.Filters.MsPortalFx.TimeRange",
                            "value": {
                                "relative": {
                                    "duration": 24,
                                    "timeUnit": 1
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    "name": "TaskFlow Monitoring Dashboard",
    "version": "1.0"
}
EOF

# Create the dashboard
az portal dashboard create \
    --resource-group $RESOURCE_GROUP \
    --name "taskflow-monitoring-dashboard" \
    --location "East US" \
    --input-path taskflow-dashboard.json

print_status "SUCCESS" "Monitoring dashboard created"

echo ""
echo "Step 7: Testing monitoring setup..."

# Test production health
PROD_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://taskflow-app.azurewebsites.net/health)
if [ "$PROD_STATUS" = "200" ]; then
    print_status "SUCCESS" "Production health check passed"
else
    print_status "ERROR" "Production health check failed: $PROD_STATUS"
fi

# Test staging health
STAGING_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://taskflow-staging.azurewebsites.net/health)
if [ "$STAGING_STATUS" = "200" ]; then
    print_status "SUCCESS" "Staging health check passed"
else
    print_status "ERROR" "Staging health check failed: $STAGING_STATUS"
fi

echo ""
print_status "INFO" "Monitoring setup completed successfully!"
print_status "INFO" "Dashboard URL: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Portal/dashboards/taskflow-monitoring-dashboard"
print_status "INFO" "Application Insights: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/$APP_INSIGHTS_NAME"

echo ""
print_status "INFO" "Monitoring Features Configured:"
echo "- ✅ Application Insights integration"
echo "- ✅ Health check monitoring"
echo "- ✅ Performance metrics tracking"
echo "- ✅ Error rate monitoring"
echo "- ✅ Operational alarms"
echo "- ✅ Monitoring dashboard"
echo "- ✅ Availability tests"

echo ""
print_status "INFO" "Next Steps:"
echo "1. Monitor the dashboard for application performance"
echo "2. Test alert triggers by simulating issues"
echo "3. Review logs and metrics regularly"
echo "4. Adjust alert thresholds based on usage patterns" 