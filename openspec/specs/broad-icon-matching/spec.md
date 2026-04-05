## ADDED Requirements

### Requirement: Professional/business icon matching
The system SHALL display the professional icon for actions whose name contains any of: "professional", "business", "corporate", "executive".

#### Scenario: Action named "Professional Tone" gets briefcase icon
- **WHEN** an action named "Professional Tone" is displayed in the menu bar
- **THEN** the system SHALL use the `.professional` AppIcon

#### Scenario: Action named "Business Email" gets briefcase icon
- **WHEN** an action named "Business Email" is displayed in the menu bar
- **THEN** the system SHALL use the `.professional` AppIcon

### Requirement: Simplify/ELI5 icon matching
The system SHALL display the simplify icon for actions whose name contains any of: "eli5", "simplify", "simple", "easy", "beginner", "basics".

#### Scenario: Action named "ELI5" gets simplify icon
- **WHEN** an action named "ELI5" is displayed in the menu bar
- **THEN** the system SHALL use the `.simplify` AppIcon

#### Scenario: Action named "Simplify Language" gets simplify icon
- **WHEN** an action named "Simplify Language" is displayed in the menu bar
- **THEN** the system SHALL use the `.simplify` AppIcon

### Requirement: Expand/elaborate icon matching
The system SHALL display the expand icon for actions whose name contains any of: "expand", "elaborate", "extend", "lengthen", "detail", "longer".

#### Scenario: Action named "Expand on This" gets expand icon
- **WHEN** an action named "Expand on This" is displayed in the menu bar
- **THEN** the system SHALL use the `.expand` AppIcon

### Requirement: Email/message icon matching
The system SHALL display the email icon for actions whose name contains any of: "email", "mail", "letter", "message", "memo".

#### Scenario: Action named "Draft Email" gets email icon
- **WHEN** an action named "Draft Email" is displayed in the menu bar
- **THEN** the system SHALL use the `.email` AppIcon

### Requirement: Chat/conversation icon matching
The system SHALL display the chat icon for actions whose name contains any of: "chat", "conversation", "dialogue", "reply", "respond".

#### Scenario: Action named "Reply Politely" gets chat icon
- **WHEN** an action named "Reply Politely" is displayed in the menu bar
- **THEN** the system SHALL use the `.chat` AppIcon

### Requirement: Code/technical icon matching
The system SHALL display the code icon for actions whose name contains any of: "code", "program", "technical", "developer", "debug", "script".

#### Scenario: Action named "Code Review" gets code icon
- **WHEN** an action named "Code Review" is displayed in the menu bar
- **THEN** the system SHALL use the `.code` AppIcon

### Requirement: Creative/brainstorm icon matching
The system SHALL display the creative icon for actions whose name contains any of: "creative", "brainstorm", "idea", "inspire", "imagine".

#### Scenario: Action named "Creative Writing" gets creative icon
- **WHEN** an action named "Creative Writing" is displayed in the menu bar
- **THEN** the system SHALL use the `.creative` AppIcon

### Requirement: Formal/academic icon matching
The system SHALL display the formal icon for actions whose name contains any of: "formal", "academic", "scholarly", "essay", "thesis", "research".

#### Scenario: Action named "Academic Tone" gets formal icon
- **WHEN** an action named "Academic Tone" is displayed in the menu bar
- **THEN** the system SHALL use the `.formal` AppIcon

### Requirement: Casual/friendly icon matching
The system SHALL display the casual icon for actions whose name contains any of: "casual", "friendly", "relaxed", "informal", "chill".

#### Scenario: Action named "Casual Tone" gets casual icon
- **WHEN** an action named "Casual Tone" is displayed in the menu bar
- **THEN** the system SHALL use the `.casual` AppIcon

### Requirement: List/organize icon matching
The system SHALL display the list icon for actions whose name contains any of: "list", "bullet", "outline", "organize", "format", "structure".

#### Scenario: Action named "Convert to Bullet List" gets list icon
- **WHEN** an action named "Convert to Bullet List" is displayed in the menu bar
- **THEN** the system SHALL use the `.list` AppIcon

### Requirement: Tone/sentiment icon matching
The system SHALL display the tone icon for actions whose name contains any of: "tone", "mood", "sentiment", "emotion", "feel", "voice".

#### Scenario: Action named "Change Tone" gets tone icon
- **WHEN** an action named "Change Tone" is displayed in the menu bar
- **THEN** the system SHALL use the `.tone` AppIcon

### Requirement: Magic/transform icon matching
The system SHALL display the magic icon for actions whose name contains any of: "magic", "transform", "convert", "auto".

#### Scenario: Action named "Auto-Format" gets magic icon
- **WHEN** an action named "Auto-Format" is displayed in the menu bar
- **THEN** the system SHALL use the `.magic` AppIcon

### Requirement: Heading/title icon matching
The system SHALL display the heading icon for actions whose name contains any of: "heading", "title", "headline", "caption".

#### Scenario: Action named "Generate Title" gets heading icon
- **WHEN** an action named "Generate Title" is displayed in the menu bar
- **THEN** the system SHALL use the `.heading` AppIcon

### Requirement: Hashtag/tag icon matching
The system SHALL display the hashtag icon for actions whose name contains any of: "hashtag", "tag", "keyword", "seo".

#### Scenario: Action named "Generate Hashtags" gets hashtag icon
- **WHEN** an action named "Generate Hashtags" is displayed in the menu bar
- **THEN** the system SHALL use the `.hashtag` AppIcon

### Requirement: Icon matching priority order
The system SHALL evaluate icon keyword matches from most specific to least specific, returning the first match. The `.textDefault` fallback icon SHALL be used only when no keywords match.

#### Scenario: Action with multiple matching keywords uses first match
- **WHEN** an action name matches keywords from multiple icon categories
- **THEN** the system SHALL use the icon from the first matching rule in evaluation order

#### Scenario: Action with no matching keywords gets fallback icon
- **WHEN** an action name does not match any keyword pattern
- **THEN** the system SHALL use the `.textDefault` fallback icon
