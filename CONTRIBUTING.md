# Contributing to GymLive

## Development Workflow

1. **Create a Feature Branch**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Write your code
   - Commit regularly with meaningful commit messages
   - Keep commits focused and atomic

3. **Push Changes**
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create Pull Request**
   - Go to GitHub repository
   - Create a new Pull Request from your feature branch to main
   - Add description of changes
   - Request review if required

5. **Code Review**
   - Address any review comments
   - Make requested changes
   - Push additional commits to the same branch

6. **Merge**
   - Once approved, merge the PR
   - Delete the feature branch

## Branch Naming Convention

- Feature branches: `feature/description-of-feature`
- Bug fixes: `fix/description-of-bug`
- Refactoring: `refactor/description-of-changes`
- Documentation: `docs/description-of-changes`

## Commit Message Guidelines

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests when relevant

## Code Style

- Follow existing code style and conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and manageable in size

## Testing

- Add tests for new features
- Ensure all tests pass before submitting PR
- Update existing tests when modifying features
- **Pull requests will not be merged without unit tests demonstrating the functionality of the proposed feature**