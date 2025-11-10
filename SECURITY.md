# Security Policy

## Supported Versions

We take security seriously and actively maintain the following versions of GrabTube:

| Version | Supported          | Status      |
| ------- | ------------------ | ----------- |
| 0.5.x   | :white_check_mark: | Current     |
| 0.4.x   | :white_check_mark: | Maintained  |
| 0.3.x   | :x:                | End of Life |
| < 0.3   | :x:                | End of Life |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

### How to Report

If you discover a security vulnerability, please send an email to:

**security@grabtube.example.com** (Update with actual email)

Include the following information:

1. **Type of vulnerability** (e.g., XSS, SQL injection, arbitrary code execution)
2. **Affected component** (e.g., Flutter client, Python backend, Angular frontend)
3. **Affected version(s)**
4. **Step-by-step instructions** to reproduce the issue
5. **Proof of concept** or exploit code (if applicable)
6. **Potential impact** of the vulnerability
7. **Suggested fix** (if you have one)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 48 hours
- **Investigation**: We will investigate and validate the issue within 5 business days
- **Updates**: We will keep you informed of our progress at least every 7 days
- **Resolution**: We aim to resolve critical vulnerabilities within 30 days
- **Disclosure**: We will coordinate disclosure with you after the fix is released

### Vulnerability Disclosure Policy

- **Coordinated Disclosure**: We follow responsible disclosure practices
- **Credit**: We will credit you in the security advisory (unless you prefer to remain anonymous)
- **Public Disclosure**: We will publish a security advisory after the fix is released
- **CVE Assignment**: We will request CVE IDs for significant vulnerabilities

## Security Best Practices

### For Users

#### General Security

1. **Keep Updated**: Always use the latest version of GrabTube
2. **Verify Downloads**: Check file hashes before executing downloaded files
3. **Use HTTPS**: Ensure the backend server uses HTTPS in production
4. **Strong Passwords**: If authentication is added, use strong, unique passwords
5. **Review Permissions**: Understand what permissions the app requests

#### Network Security

1. **Trusted Networks**: Use GrabTube on trusted networks only
2. **VPN**: Consider using a VPN when downloading from untrusted sources
3. **Firewall**: Configure firewall rules to limit backend access
4. **API Keys**: Keep yt-dlp API keys and credentials secure

#### Data Privacy

1. **Download Location**: Store downloads in secure, private directories
2. **History**: Regularly clear download history if privacy is a concern
3. **Logs**: Be aware that download URLs are logged
4. **Cookies**: Handle authentication cookies securely

### For Developers

#### Code Security

1. **Input Validation**:
   ```dart
   // Always validate and sanitize user input
   String sanitizeUrl(String url) {
     final uri = Uri.tryParse(url);
     if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
       throw ArgumentError('Invalid URL');
     }
     return url;
   }
   ```

2. **SQL Injection Prevention**:
   - Use parameterized queries
   - Never concatenate user input into SQL
   - Use ORM libraries (e.g., Hive for Flutter, SQLite with parameters)

3. **XSS Prevention**:
   - Sanitize all user-generated content
   - Use framework-provided sanitization (Angular's DomSanitizer)
   - Implement Content Security Policy (CSP)

4. **Command Injection Prevention**:
   ```python
   # BAD: Never do this
   os.system(f"yt-dlp {user_url}")

   # GOOD: Use subprocess with args list
   subprocess.run(['yt-dlp', user_url], check=True)
   ```

5. **Path Traversal Prevention**:
   ```dart
   // Prevent directory traversal attacks
   String sanitizePath(String filename) {
     final clean = path.basename(filename);
     if (clean.contains('..') || clean.startsWith('/')) {
       throw ArgumentError('Invalid filename');
     }
     return clean;
   }
   ```

#### Authentication & Authorization

1. **JWT Security**:
   - Use strong secret keys (min 256 bits)
   - Implement token expiration
   - Refresh tokens securely
   - Validate all claims

2. **Password Handling**:
   - Never store passwords in plain text
   - Use bcrypt, Argon2, or PBKDF2
   - Implement rate limiting on login attempts
   - Enforce password complexity requirements

3. **API Security**:
   - Require authentication for sensitive endpoints
   - Implement rate limiting
   - Use CORS appropriately
   - Validate all inputs

#### Dependency Security

1. **Regular Updates**:
   ```bash
   # Flutter
   flutter pub outdated
   flutter pub upgrade

   # Python
   uv sync --upgrade

   # Angular
   npm audit
   npm update
   ```

2. **Vulnerability Scanning**:
   - Run `npm audit` for Angular dependencies
   - Use `safety` for Python dependencies: `uv run safety check`
   - Monitor GitHub Dependabot alerts

3. **Minimal Dependencies**:
   - Only include necessary dependencies
   - Review dependency licenses
   - Check dependency maintainer reputation

#### Secure Communication

1. **HTTPS Only**:
   ```python
   # Enforce HTTPS in production
   if not request.url.scheme == 'https':
       raise HTTPException(status_code=403, detail="HTTPS required")
   ```

2. **WebSocket Security**:
   - Use WSS (WebSocket Secure) in production
   - Implement authentication for Socket.IO
   - Validate all incoming messages

3. **Certificate Validation**:
   - Never disable SSL certificate validation
   - Pin certificates for critical connections

#### Data Protection

1. **Sensitive Data**:
   - Never log passwords, tokens, or API keys
   - Encrypt sensitive data at rest
   - Use secure storage APIs (Keychain, Keystore)

2. **Secrets Management**:
   ```bash
   # Use environment variables for secrets
   export YTDL_API_KEY="your-secret-key"

   # Never commit secrets to Git
   # Add to .gitignore:
   .env
   *.key
   secrets/
   ```

3. **Data Minimization**:
   - Only collect necessary data
   - Implement data retention policies
   - Provide data export/deletion options

#### Error Handling

1. **Don't Leak Information**:
   ```python
   # BAD: Exposes internal details
   return {"error": str(exception)}

   # GOOD: Generic error message
   logger.error(f"Error: {exception}")
   return {"error": "An error occurred"}
   ```

2. **Logging Best Practices**:
   - Log security events (failed logins, unusual activity)
   - Don't log sensitive data
   - Implement log rotation
   - Monitor logs for suspicious patterns

## Known Security Considerations

### Current Architecture

1. **Download Execution**:
   - yt-dlp runs with user permissions
   - Downloaded files are not sandboxed
   - Malicious video metadata could cause issues

2. **WebSocket Communication**:
   - Currently no authentication required
   - Should be restricted to localhost or authenticated users

3. **File System Access**:
   - App has access to download directory
   - Should implement permission checks

### Planned Improvements

1. **Authentication System** (v1.1.0):
   - User accounts with JWT tokens
   - Role-based access control
   - API key management

2. **Sandboxing** (v1.2.0):
   - Isolate yt-dlp execution
   - Implement download size limits
   - Validate file types

3. **Audit Logging** (v1.1.0):
   - Track all security-relevant events
   - Implement anomaly detection
   - Generate security reports

## Security Features

### Current Implementation

1. **Input Validation**:
   - URL validation before download
   - File path sanitization
   - Format string validation

2. **Error Handling**:
   - Graceful error handling
   - No sensitive information in error messages
   - Comprehensive logging

3. **Dependency Management**:
   - Regular dependency updates
   - Vulnerability scanning in CI/CD
   - License compliance checks

### Coming Soon

1. **Rate Limiting**: Prevent abuse of download API
2. **User Authentication**: Secure access to download queue
3. **Download Quotas**: Limit resource usage per user
4. **Content Filtering**: Block malicious or inappropriate content

## Compliance

### Data Protection

- **GDPR**: We don't collect personal data by default
- **CCPA**: Users can request data deletion
- **Data Retention**: Download history can be cleared by users

### Licensing

- **yt-dlp**: Unlicense (public domain)
- **FFmpeg**: LGPL 2.1+ (ensure compliance)
- **Dependencies**: Various open-source licenses (see package files)

## Security Checklist for Contributors

Before submitting code, verify:

- [ ] All user inputs are validated and sanitized
- [ ] No secrets or credentials in code
- [ ] Dependencies are up to date
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No command injection vulnerabilities
- [ ] No path traversal vulnerabilities
- [ ] Error messages don't leak sensitive information
- [ ] Logging doesn't include sensitive data
- [ ] HTTPS is enforced where applicable
- [ ] Authentication is implemented for sensitive operations
- [ ] Tests include security test cases

## Security Testing

### Automated Testing

1. **Static Analysis**:
   ```bash
   # Dart
   flutter analyze

   # Python
   uv run pylint app/
   uv run bandit -r app/

   # JavaScript/TypeScript
   npm run lint
   ```

2. **Dependency Scanning**:
   ```bash
   # Python
   uv run safety check

   # Node.js
   npm audit

   # Flutter
   flutter pub outdated
   ```

### Manual Testing

1. **Input Fuzzing**: Test with malformed inputs
2. **Boundary Testing**: Test edge cases and limits
3. **Permission Testing**: Verify access controls work
4. **Injection Testing**: Try SQL, command, and XSS injection
5. **Authentication Testing**: Verify auth mechanisms
6. **Session Testing**: Check session handling

## Security Contacts

- **Security Issues**: security@grabtube.example.com (Update with actual email)
- **General Contact**: support@grabtube.example.com (Update with actual email)
- **GitHub Security Advisories**: https://github.com/USERNAME/GrabTube/security/advisories

## Hall of Fame

We appreciate security researchers who responsibly disclose vulnerabilities:

<!-- Will be updated as security reports are received and resolved -->

*No reports received yet*

---

**Last Updated**: November 10, 2025

Thank you for helping keep GrabTube and our users safe!
