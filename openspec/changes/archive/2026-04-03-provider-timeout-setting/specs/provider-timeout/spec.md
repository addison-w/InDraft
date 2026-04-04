# Provider Timeout

## Scenarios

### Default timeout value
- **GIVEN** a newly created Provider
- **WHEN** no timeout is explicitly set
- **THEN** `timeoutSeconds` is 30

### Timeout applied to API requests
- **GIVEN** a provider with `timeoutSeconds` set to 60
- **WHEN** `transform()` is called for that provider
- **THEN** the URLRequest's `timeoutInterval` is set to 60

### Timeout applied to test connection
- **GIVEN** a provider with `timeoutSeconds` set to 45
- **WHEN** `testConnection()` is called for that provider
- **THEN** the URLRequest's `timeoutInterval` is set to 45

### Slider range enforcement
- **GIVEN** the provider timeout slider in the inline editor
- **WHEN** the user adjusts the slider
- **THEN** the minimum value is 10 seconds
- **AND** the maximum value is 180 seconds
- **AND** the step increment is 5 seconds

### Slider displays current value
- **GIVEN** a provider with `timeoutSeconds` set to 60
- **WHEN** the user views the timeout slider
- **THEN** a label shows "60s"

### Timeout persists on provider model
- **GIVEN** the user sets timeout to 90 via the slider
- **WHEN** the provider is saved and reloaded
- **THEN** `timeoutSeconds` is 90
