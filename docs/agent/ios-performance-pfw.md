# iOS Performance + Point-Free Workshop Expert

Expert iOS performance optimization with integrated Point-Free Workshop (PFW) expertise for modern Swift applications.

## When to Use This Skill

**Automatically trigger for:**
- iOS performance issues: memory leaks, UI lag, crashes, battery drain
- TCA (The Composable Architecture) problems: ifCaseLet errors, state management, effect cancellation
- SwiftUI performance optimization and navigation patterns  
- Point-Free library integration: Composable Architecture, Perception, Swift Navigation
- Any mention of "performance", "optimization", "TCA", "Point-Free", or related terms

## Core Capabilities

### 1. iOS Performance Analysis & Optimization

#### Memory Management
- Detect and fix retain cycles using Instruments
- ARC optimization patterns
- Weak/unowned reference best practices
- Memory leak prevention in closures and delegates

#### UI Performance  
- SwiftUI view optimization
- Reduce view body computations
- Efficient list rendering with LazyVStack/LazyHStack
- Image loading and caching optimization

#### Battery & CPU Optimization
- Background task management
- Location services optimization
- Network request batching
- CPU-intensive operation profiling

### 2. Point-Free Workshop Integration

#### The Composable Architecture (TCA)
**Always reference:** `references/pfw-tca-patterns.md`

Key patterns:
- Proper reducer composition with `CombineReducers`
- Effect cancellation with `CancelID`
- State management with `@ObservableState`
- Navigation with `StackState` and `PresentationAction`

#### TCA Performance Optimization
- Effect lifecycle management
- State normalization strategies  
- Reducing unnecessary view updates
- Memory-efficient store scoping

#### Swift Navigation Patterns
**Reference:** `references/pfw-navigation.md`

- Stack-based navigation
- Declarative routing
- Deep link handling
- Navigation state persistence

#### Perception Library
**Reference:** `references/pfw-perception.md`

- Observation back-porting for iOS < 17
- Performance benefits over traditional observation
- Integration with TCA stores

#### WeaveDI Integration
**Modern Dependency Injection Support**

- WeaveDI 3.4.0 @DependencyConfiguration patterns
- Performance-optimized dependency resolution
- TCA + WeaveDI integration best practices
- Memory-efficient dependency management

## 3. Performance Debugging Workflow

### Step 1: Identify Performance Issues
```swift
// Use Instruments to profile:
// - Time Profiler: CPU hotspots
// - Allocations: Memory leaks  
// - Core Animation: UI performance
// - Energy Impact: Battery usage
```

### Step 2: Apply PFW Best Practices
```swift
// TCA Effect Cancellation
enum CancelID: Hashable { case apiRequest }

return .run { send in
  // Long-running operation
}
.cancellable(id: CancelID.apiRequest, cancelInFlight: true)
```

### Step 3: Optimize Based on Findings
- **Memory leaks** → Fix retain cycles, use weak references
- **UI lag** → Optimize view hierarchies, reduce body computations
- **TCA issues** → Apply proper effect management and state design
- **Navigation problems** → Use PFW navigation patterns

## 4. Integration Examples

### TCA + Performance Optimization
```swift
@Reducer
struct PerformantFeature {
  @ObservableState
  struct State {
    // Normalize collections for O(1) lookups
    var items: IdentifiedArrayOf<Item> = []
    
    // Separate loading states to minimize updates
    var isLoading = false
  }
  
  enum Action {
    case loadItems
    case itemsLoaded([Item])
  }
  
  enum CancelID { case loadItems }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .loadItems:
        state.isLoading = true
        return .run { send in
          let items = try await apiClient.loadItems()
          await send(.itemsLoaded(items))
        }
        .cancellable(id: CancelID.loadItems, cancelInFlight: true)
        
      case .itemsLoaded(let items):
        state.items = IdentifiedArray(uniqueElements: items)
        state.isLoading = false
        return .none
      }
    }
  }
}
```

### SwiftUI + TCA Performance
```swift
struct PerformantView: View {
  let store: StoreOf<PerformantFeature>
  
  var body: some View {
    // Minimize store observations
    let items = store.items
    let isLoading = store.isLoading
    
    Group {
      if isLoading {
        ProgressView()
      } else {
        // Use LazyVStack for large lists
        LazyVStack {
          ForEach(items) { item in
            ItemView(item: item)
          }
        }
      }
    }
    .onAppear {
      store.send(.loadItems)
    }
  }
}
```

## 5. Troubleshooting Common Issues

### TCA ifCaseLet Errors
**Pattern:** Child action received when state was different case
**Solution:** Proper effect cancellation and state transition management

```swift
// In parent reducer
Reduce { state, action in
  switch action {
  case .navigationAction(let navAction):
    // Cancel all child effects before state change
    return .merge(
      .cancel(id: ChildCancelID.allEffects),
      handleNavigation(state: &state, action: navAction)
    )
  }
}
```

### SwiftUI Performance Issues
**Pattern:** Views updating unnecessarily
**Solution:** Minimize store subscriptions and optimize view bodies

```swift
// Bad: Too many observations
struct BadView: View {
  @Bindable var store: StoreOf<Feature>
  
  var body: some View {
    VStack {
      Text(store.title) // Subscribes to all state changes
      Text(store.subtitle) // Another subscription
      Text("\(store.count)") // Another subscription
    }
  }
}

// Good: Single observation point
struct GoodView: View {
  let store: StoreOf<Feature>
  
  var body: some View {
    let state = store.state // Single observation
    
    VStack {
      Text(state.title)
      Text(state.subtitle) 
      Text("\(state.count)")
    }
  }
}
```

## 6. Performance Testing & Validation

### Automated Performance Tests
```swift
func testTCAPerformance() {
  let store = TestStore(initialState: Feature.State()) {
    Feature()
  }
  
  // Measure effect cancellation time
  let startTime = CFAbsoluteTimeGetCurrent()
  store.send(.cancelAllEffects)
  let endTime = CFAbsoluteTimeGetCurrent()
  
  XCTAssertLessThan(endTime - startTime, 0.1) // < 100ms
}
```

### Memory Leak Detection
```swift
weak var weakStore: Store<Feature.State, Feature.Action>?

func testNoRetainCycles() {
  autoreleasepool {
    let store = Store(initialState: Feature.State()) {
      Feature()
    }
    weakStore = store
    // Use store...
  }
  
  XCTAssertNil(weakStore, "Store should be deallocated")
}
```

## Next Steps

1. **Profile first**: Use Instruments to identify actual bottlenecks
2. **Apply PFW patterns**: Use proven architectural patterns from Point-Free
3. **Measure impact**: Validate optimizations with performance tests
4. **Iterate**: Continuous monitoring and improvement

For complex performance issues, consider reading the detailed reference files for specific PFW patterns and advanced optimization techniques.