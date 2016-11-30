
struct S{
};

typedef S MS;

void update( S &s );

void update2( const S *s );

void update3( const MS *s );

class C{
	public:
	
	int x,y,z;
	
	void update( S &s );
	
	const S &render();
};

float A,B,C;

