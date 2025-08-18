# NomAI Chat Module

A comprehensive Flutter chat interface for the NomAI nutrition assistant app, featuring real-time messaging, nutrition data visualization, and responsive design.

## Features

- **Real-time Chat**: Stream-based messaging with typing indicators
- **Nutrition Analysis**: Detailed breakdown of food nutrition data
- **Beautiful UI**: Modern design with gradients, animations, and responsive layout
- **Health Assessment**: Visual health scores and recommendations
- **Ingredient Breakdown**: Detailed nutritional analysis per ingredient
- **Alternatives Suggestions**: Healthier food alternatives
- **Error Handling**: Graceful error handling with retry options
- **Demo Mode**: Works offline with mock data when API is unavailable

## Architecture

### Files Structure
```
lib/app/modules/Chat/
├── Views/
│   └── chat_view.dart          # Main chat UI
├── controller/
│   └── chat_controller.dart    # Chat logic and state management
└── README.md                   # This file

lib/app/repo/
└── agent_service.dart          # API communication service

lib/app/models/Agent/
└── agent_response.dart         # Data models for chat messages
```

### Key Components

1. **NomAiAgentView**: Main chat interface widget
2. **ChatController**: GetX controller managing chat state
3. **AgentService**: HTTP service for API communication
4. **AgentResponse**: Data model for chat messages

## API Integration

The chat module connects to a backend API at `http://localhost:8000` with the following endpoints:

- `GET /chat/messages?user_id={userId}` - Retrieve chat history
- `POST /chat/messages` - Send new message (streaming response)

### Expected Response Format

```json
{
  "role": "model",
  "timestamp": "2025-08-19T01:17:52.281840",
  "content": "Analysis complete!",
  "is_final": true,
  "tool_returns": [
    {
      "tool_name": "calculate_nutrition_by_food_description",
      "tool_call_id": "call_123",
      "content": {
        "response": {
          "foodName": "Chicken Salad",
          "portion": "cup",
          "portionSize": 2,
          "confidenceScore": 8,
          "ingredients": [...],
          "overallHealthScore": 7,
          "primaryConcerns": [...],
          "suggestAlternatives": [...]
        }
      }
    }
  ]
}
```

## Usage

### Basic Integration

```dart
import 'package:NomAi/app/modules/Chat/Views/chat_view.dart';

// Navigate to chat
Get.to(() => const NomAiAgentView());
```

### Controller Access

```dart
final ChatController controller = Get.find<ChatController>();

// Send message
controller.messageController.text = "Tell me about pizza nutrition";
controller.sendMessage();

// Clear history
controller.clearMessages();

// Load history
controller.loadChatHistory();
```

## Customization

### Colors and Theming

Key colors used in the chat interface:

```dart
// Primary colors
const Color(0xFF6366F1) // Primary blue
const Color(0xFF10b981) // Success green
const Color(0xFF047857) // Dark green
const Color(0xFFF59E0B) // Warning orange
const Color(0xFFEF4444) // Error red

// Gradients
LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]) // Header
LinearGradient(colors: [Color(0xFF10b981), Color(0xFF047857)]) // Success
```

### Layout Customization

- Message max width: 70% of screen width
- Animation duration: 300ms + 50ms per message index
- Typography: Inter font family with various weights
- Border radius: 16px for containers, 24px for inputs

## Demo Mode Features

When the API server is not available, the app automatically switches to demo mode with the following features:

- **Visual Indicator**: "DEMO" badge in the header
- **Enhanced Empty State**: Shows clickable food suggestion chips
- **Smart Food Recognition**: Recognizes specific food items and provides relevant nutrition data:
  - 🍕 Pizza → Detailed pizza nutrition with health concerns
  - 🥗 Salad → Healthy salad analysis with high scores
  - 🍔 Burger → Burger analysis with alternative suggestions  
  - 🍎 Apple → Fruit nutrition with health benefits
  - 🍌 Banana → Banana nutrition with potassium benefits
- **Generic Responses**: For unrecognized foods, provides general nutrition guidance
- **No Error Messages**: Seamless fallback without disrupting user experience

### Triggering Demo Mode

Demo mode is automatically activated when:
- API server is not running (`Connection refused`)
- Network connectivity issues (`SocketException`)  
- HTTP client errors (`ClientException`)

## Troubleshooting

### Common Issues

1. **GetX Error**: "improper use of a GetX has been detected"
   - **Solution**: Use `GetBuilder` instead of `Obx` for non-observable variables
   - **Fixed in**: User ID display now uses `GetBuilder<ChatController>`

2. **RenderFlex Overflow**: Layout constraints exceeded
   - **Solution**: Improved layout with proper `Flexible` and `ConstrainedBox`
   - **Fixed in**: Input area restructured with better constraints

3. **Connection Refused**: API server not running
   - **Fallback**: Demo messages automatically loaded
   - **Check**: Ensure backend server is running on port 8000

### Debug Mode

Enable debug logging by setting:

```dart
// In agent_service.dart
static const bool enableDebugLogs = true;
```

## Performance Optimization

- **Lazy Loading**: Messages loaded on-demand
- **Stream Management**: Proper subscription cleanup
- **Animation Optimization**: Hardware-accelerated transforms
- **Memory Management**: Controller disposal in `onClose()`

## Accessibility

- **Semantic Labels**: Proper labels for screen readers
- **Keyboard Navigation**: Full keyboard support
- **Color Contrast**: WCAG compliant color ratios
- **Focus Management**: Proper focus handling

## Dependencies

```yaml
dependencies:
  flutter: ^3.0.0
  get: ^4.6.5
  http: ^0.13.0
  intl: ^0.18.0
```

## Testing

### Manual Testing Checklist

- [ ] Send message with API connection
- [ ] Send message without API connection (demo mode)
- [ ] User ID change triggers history reload
- [ ] Typing indicator shows/hides properly
- [ ] Nutrition cards display correctly
- [ ] Animations work smoothly
- [ ] Error handling works
- [ ] Responsive layout on different screen sizes

### Unit Tests

```dart
// Example test structure
testWidgets('Chat sends message on button tap', (WidgetTester tester) async {
  // Test implementation
});
```

## Future Enhancements

- [ ] Voice input support
- [ ] Image upload for food analysis
- [ ] Chat export functionality
- [ ] Push notifications
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Custom nutrition goal tracking
