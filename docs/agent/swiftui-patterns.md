# SwiftUI 코딩 패턴 가이드

## 🎨 SwiftUI 코드 스타일

### 뷰 구조화

```swift
// ✅ 올바른 패턴
struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileFeature>
    
    var body: some View {
        VStack {
            profileHeader
            profileContent  
            actionButtons
        }
        .navigationTitle("프로필")
    }
    
    // SubView는 분리된 struct로
    private var profileHeader: some View {
        ProfileHeaderView(user: store.user)
    }
    
    private var profileContent: some View {
        VStack {
            // 내용
        }
    }
}

// SubView는 별도 struct
struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        // UI 구현
    }
}
```

### 네이밍 규칙

- **View suffix 생략**: `LoginView` → `Login` 
- **Action 네이밍**: 이벤트 기반 `loginButtonTapped`, `textFieldChanged`
- **State 프로퍼티**: 명확한 의미 `isLoading`, `errorMessage`, `user`

### 레이아웃 패턴

```swift
// ✅ frame 활용한 공간 할당
VStack {
  header
  Spacer()
    .frame(maxHeight: .infinity)  // Spacer() 대신
  footer
}

// ✅ Binding을 통한 상태 전달
TextField("이메일", text: $store.email.sending(\.emailChanged))
  .textFieldStyle(.roundedBorder)
```

## 🏗️ SwiftUI View Extension 패턴 (실제 프로젝트 활용법)

### 1. View 컴포넌트 분리

```swift
struct HomeView: View {
  @Bindable var store: StoreOf<HomeFeature>
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topLeading) {
        logoContentView(geometry: geometry)
        mainContentView()
      }
    }
  }
}

// MARK: - View Components (Extension으로 분리)
extension HomeView {
  @ViewBuilder
  fileprivate func logoContentView(geometry: GeometryProxy) -> some View {
    ZStack(alignment: .top) {
      Image(asset: .homeLogo)
        .resizable()
        .scaledToFill()
        .frame(width: geometry.size.width, height: Layout.Hero.height)
        .scaleEffect(1.06, anchor: .top)
        .ignoresSafeArea(edges: .top)
      
      VStack {
        navigationBar()
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      
      VStack(spacing: 8) {
        selectStationView()
        selectTrainTimeView()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      .padding(.bottom, 28)
    }
  }
  
  @ViewBuilder
  private func selectStationView() -> some View {
    Button {
      store.send(.view(.stationSelectionTapped))
    } label: {
      HStack {
        Text("출발역 선택")
          .pretendardCustomFont(textStyle: .body2)
          .foregroundStyle(.gray600)
        
        Spacer()
        
        if let station = store.selectedStation {
          Text(station.name)
            .pretendardCustomFont(textStyle: .body1)
            .foregroundStyle(.staticBlack)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(.staticWhite)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
  
  @ViewBuilder
  private func selectTrainTimeView() -> some View {
    VStack(spacing: 12) {
      timePickerView()
      
      if store.hasRemainingTimeResult {
        remainingTimeDisplayView()
      }
    }
  }
}
```

### 2. Computed Properties + @ViewBuilder 조합

```swift
struct ProfileView: View {
  @Bindable var store: StoreOf<ProfileFeature>
  
  var body: some View {
    ScrollView {
      profileInfoCardView()
      travelHistorySection()
    }
  }
}

extension ProfileView {
  // Computed Property로 데이터 가공
  private var travelHistoryItems: [HistoryItemEntity] {
    store.historyEntity?.items ?? []
  }
  
  private var hasHistoryData: Bool {
    !travelHistoryItems.isEmpty
  }
  
  // @ViewBuilder로 UI 컴포넌트 분리
  @ViewBuilder
  private func profileInfoCardView() -> some View {
    VStack(alignment: .leading) {
      VStack {
        Spacer()
          .frame(height: 16)
        
        HStack {
          Text("\(store.profileEntity?.nickname ?? "사용자")님")
            .pretendardCustomFont(textStyle: .heading1)
            .foregroundStyle(.staticWhite)
          
          Spacer()
        }
        .padding(.horizontal, 8)
        
        providerInfoView()
      }
    }
    .padding(.horizontal, 16)
    .background(.primaryBlue500)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
  
  @ViewBuilder
  private func providerInfoView() -> some View {
    HStack {
      switch store.profileEntity?.provider {
      case .apple:
        Image(systemName: store.profileEntity?.provider.image ?? "")
          .resizable()
          .scaledToFit()
          .frame(width: 16, height: 16)
          .foregroundStyle(.staticWhite)
        
      case .google:
        AsyncImageView(
          url: store.profileEntity?.profileImageUrl,
          placeholder: Image(systemName: "person.circle")
        )
        .frame(width: 20, height: 20)
        .clipShape(Circle())
      }
      
      Text(store.profileEntity?.email ?? "")
        .pretendardCustomFont(textStyle: .caption1)
        .foregroundStyle(.staticWhite.opacity(0.8))
      
      Spacer()
    }
    .padding(.horizontal, 8)
  }
}
```

### 3. 조건부 렌더링 + Skeleton 패턴

```swift
extension ExploreDetailView {
  @ViewBuilder
  private func contentView() -> some View {
    if store.isLoading {
      ExploreDetailSkeletonView()
    } else if let place = store.placeDetail {
      loadedContentView(place: place)
    } else {
      errorContentView()
    }
  }
  
  @ViewBuilder
  private func loadedContentView(place: PlaceDetailEntity) -> some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        placeImageSection(place: place)
        placeInfoSection(place: place)
        routeActionSection(place: place)
      }
    }
  }
  
  @ViewBuilder
  private func errorContentView() -> some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.largeTitle)
        .foregroundStyle(.gray400)
      
      Text("장소 정보를 불러올 수 없습니다")
        .pretendardCustomFont(textStyle: .body1)
        .foregroundStyle(.gray600)
      
      Button("다시 시도") {
        store.send(.view(.retryButtonTapped))
      }
      .buttonStyle(.borderedProminent)
    }
  }
}
```

## 📋 View Extension 활용 규칙

1. **@ViewBuilder**: 모든 View 분리 메서드에 필수 사용
2. **접근 제어**: `private` 또는 `fileprivate` 사용
3. **네이밍**: 동작을 명확히 표현 (`selectStationView`, `profileInfoCardView`)
4. **계층 구조**: 큰 덩어리부터 작은 컴포넌트 순으로 분리
5. **Computed Properties**: 데이터 가공 로직은 computed property로 분리
6. **조건부 렌더링**: `@ViewBuilder`로 if/else 분기 처리
7. **파일 구성**: `// MARK: -` 주석으로 섹션 구분

**이 가이드는 에이전트들이 SwiftUI 패턴을 분석하고 최적화할 때 참고하는 기준입니다.**