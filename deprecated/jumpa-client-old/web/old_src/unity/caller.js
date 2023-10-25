const caller = {
	call: (gameObject, method, arg) => {
		try {
			return window.unityInstance.SendMessage(gameObject, method, arg)
		} catch (e) {
			console.log('e', e)
		}
	},
}

export { caller }
