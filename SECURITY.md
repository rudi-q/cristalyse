# Security Policy

## Supported Versions

We actively provide security updates for the following versions of Cristalyse:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 1.1.x   | :white_check_mark: | Current stable release |
| 1.0.x   | :white_check_mark: | Maintenance support |
| < 1.0   | :x:                | End of life |

## Reporting a Vulnerability

If you discover a security vulnerability in Cristalyse, please report it privately to help us address it responsibly before public disclosure.

### How to Report

**GitHub Issues:** [Create a new issue](https://github.com/rudi-q/cristalyse/issues/new) with the "security" label  
**GitHub Discussions:** [Start a security discussion](https://github.com/rudi-q/cristalyse/discussions/new?category=security)

### What to Include

Please provide the following information to help us understand and reproduce the issue:

- **Description:** Clear explanation of the vulnerability
- **Impact:** Potential consequences (crashes, memory corruption, data exposure, etc.)
- **Reproduction:** Step-by-step instructions to reproduce the issue
- **Data samples:** Any specific datasets, chart configurations, or code that triggers the vulnerability
- **Environment:** Flutter/Dart versions, platform (iOS/Android/Web/Desktop)
- **Suggested fix:** If you have ideas for mitigation or fixes

### Response Timeline

We are committed to the following response targets:

- **Initial acknowledgment:** Within 72 hours
- **Issue assessment:** Within 1 week
- **Status updates:** As investigation progresses
- **Resolution timeline:** Varies based on severity and complexity

### Disclosure Process

We follow responsible disclosure practices:

1. **Investigation:** We validate and assess the reported issue
2. **Development:** We develop and test fixes for supported versions
3. **Coordination:** We coordinate with the reporter through GitHub before public disclosure
4. **Release:** We release security patches and publish advisories
5. **Recognition:** We credit security researchers in release notes (unless anonymity is requested)

## Security Scope

This security policy covers vulnerabilities in:

### Core Library
- Data processing and validation
- Canvas rendering operations
- Memory management during chart generation
- SVG export functionality
- Animation system security

### Dependencies
- Flutter framework integration
- Third-party package vulnerabilities (path_provider, flutter_svg, universal_html, intl)

### Platform-Specific Issues
- Cross-platform rendering inconsistencies that could lead to security issues
- Platform-specific file system operations
- Web security considerations (XSS prevention in web deployments)

## Types of Vulnerabilities We're Interested In

### High Priority
- **Memory corruption:** Buffer overflows, use-after-free, memory leaks with malicious data
- **Code injection:** Any form of code execution through data inputs
- **Path traversal:** Issues with SVG export file handling
- **Denial of service:** Inputs that cause infinite loops, excessive memory usage, or crashes

### Medium Priority
- **Data validation bypass:** Malformed data that bypasses input validation
- **Information disclosure:** Unintended exposure of data through error messages or logs
- **Dependency vulnerabilities:** Security issues in our dependencies that affect Cristalyse

### Lower Priority
- **Performance issues:** Non-security-related performance degradation
- **UI/UX issues:** Visual glitches that don't pose security risks

## What We Don't Consider Security Issues

- **Feature requests:** Suggestions for new functionality
- **Performance optimizations:** Non-security-related performance improvements
- **Compatibility issues:** Platform-specific rendering differences that don't pose security risks
- **Documentation errors:** Typos or unclear documentation
- **General bugs:** Non-security functional issues (please report these as regular GitHub issues)

## Security Best Practices for Users

When using Cristalyse in your applications:

1. **Validate data inputs:** Sanitize data before passing it to Cristalyse
2. **Keep dependencies updated:** Regularly update Cristalyse and Flutter to the latest versions
3. **Monitor dependency vulnerabilities:** Use tools like `flutter pub deps` and security scanners
4. **Limit file system access:** When using SVG export, ensure proper file path validation
5. **Test with edge cases:** Validate your charts with malformed or extreme data inputs

## Security Updates

Security updates are released as patch versions (e.g., 1.1.1, 1.1.2) and are backward compatible within the same minor version. Critical security updates may be backported to previous minor versions still under support.

## Contact

For all Cristalyse-related communications:
- **Security issues:** [GitHub Issues](https://github.com/rudi-q/cristalyse/issues) (use "security" label)
- **General questions:** [GitHub Discussions](https://github.com/rudi-q/cristalyse/discussions)
- **Bug reports:** [GitHub Issues](https://github.com/rudi-q/cristalyse/issues)

We appreciate the security research community's efforts to keep Cristalyse safe for all users.
