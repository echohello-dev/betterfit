const { Button, Logo } = window.BetterFitDesignSystem_6a70ea;

function SignInScreen({ onSignIn, onGuest }) {
  return (
    <>
      <StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, display: 'grid', placeItems: 'center', padding: 24 }}>
          <div style={{ textAlign: 'center' }}>
            <Logo variant="wordmark" height={200} assetBase="../../assets" style={{ margin: '0 auto', borderRadius: 28 }} />
            <div style={{ marginTop: 24, fontSize: 'var(--text-title-3)', color: 'var(--text-secondary)' }}>Your strength training coach</div>
          </div>
        </div>
        <div style={{ padding: '0 24px 12px', display: 'flex', flexDirection: 'column', gap: 12 }}>
          <Button icon="apple-logo" onClick={onSignIn}>Continue with Apple</Button>
          <Button variant="secondary" icon="google-logo" onClick={onSignIn}>Sign in with Google</Button>
          <Button variant="secondary" icon="envelope" onClick={onSignIn}>Sign in with email</Button>
          <Button variant="ghost" onClick={onGuest}>Continue as guest</Button>
        </div>
        <div style={{ padding: '4px 40px 28px', textAlign: 'center', fontSize: 'var(--text-caption)', color: 'var(--text-secondary)', textWrap: 'pretty' }}>
          We value your privacy. Guest mode stores data on this device only.
        </div>
      </div>
    </>
  );
}

Object.assign(window, { SignInScreen });
