# NomAI Project - Copilot Instructions

## Project Overview

NomAI is a comprehensive Flutter application for meal planning and nutrition tracking. It leverages AI to provide personalized meal recommendations, track nutritional intake, and manage dietary preferences.

## Architecture & Project Structure

### Tech Stack

- **Framework**: Flutter/Dart
- **State Management**: GetX controllers, BLoC pattern for authentication
- **Backend**: Firebase (Firestore, Auth, Storage, Functions)
- **UI**: Custom components with Sizer for responsive design



## Coding Standards & Best Practices

### File Organization

- Use descriptive file names with camelCase
- Group related files in feature-based directories
- Separate models, screens, controllers, and components
- Use `components/` subdirectories for reusable widgets

### Naming Conventions

- **Classes**: PascalCase (e.g., `MembershipModel`, `MembershipController`)
- **Variables**: camelCase (e.g., `membershipList`, `isAutoRenewal`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `ADD_MEMBER`, `UPLOAD_CSV`)
- **Files**: camelCase with descriptive names (e.g., `membershipDetailScreen.dart`)
- **Enums**: PascalCase with descriptive values (e.g., `MembershipStatus.MembershipAccepted`)

### Code Structure

- Always extend `Equatable` for data models to enable value comparison
- Use `required` parameters for mandatory fields in constructors
- Implement `copyWith()` methods for immutable model updates
- Include `toJson()` and `fromJson()` methods for serialization
- Use null-safe Dart syntax consistently

### Widget Guidelines

- Prefer StatelessWidget when possible
- Use GetX controllers for state management in membership module
- Implement proper disposal of controllers and text controllers
- Use `Sizer` package for responsive UI (e.g., `16.sp`, `2.h`, `4.w`)
- Follow Material Design principles with custom FeatsColors

## Membership Module Specifications

### Core Models

### Error Handling

- Use try-catch blocks for API calls
- Display user-friendly error messages with EasyLoading
- Log errors with custom MyLog mixin
- Graceful fallbacks for missing data

### Loading States

- Use `FutureBuilder` for async data loading
- Show appropriate loading indicators
- Handle empty states with custom illustrations

### Navigation

- Use Get.to() for navigation in GetX-managed screens
- Pass required models/IDs as constructor parameters
- Handle back navigation with proper state cleanup

### API Integration

- Use providers in `lib/providers/` for API calls
- Follow repository pattern with service locator
- Implement proper error handling and retries
- Cache frequently accessed data appropriately

## Development Guidelines

### Performance Guidelines

- Use pagination for large member lists
- Implement search with debouncing (900ms)
- Optimize image loading with CachedNetworkImage
- Use ListView.builder for dynamic lists

### Security Notes

- Never expose Stripe/payment secrets in client code
- Validate user permissions before API calls
- Sanitize user inputs, especially in forms
- Follow Firebase security rules for data access

## Module-Specific Notes

### Membership Module

- Organizations can create multiple membership types
- Support for recurring and one-time payments
- QR code generation for member verification
- Bulk member management via CSV upload
- Activity logging for audit trails
- Integration with notification system

### Future Module Guidelines

When implementing other modules (events, donations, cohorts), follow these patterns:

- Create similar model hierarchies with proper serialization
- Use consistent status enums and state management
- Implement similar controller patterns with GetX
- Follow the same screen navigation and UI patterns
- Maintain consistent error handling and loading states
