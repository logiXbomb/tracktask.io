const typeKey = key => {
	cy.get('body').type(key);
}

const addTask = (title) => {
	typeKey('oi');
	cy.focused().type(title, { delay: 100 });
	typeKey('{esc}');
} 

describe('hmmm', () => {
	it('does stuff', () => {
		cy.visit('/');
		addTask('banana');
		addTask('waffles');
		addTask('syrup');
		typeKey('mk');
	});
});
